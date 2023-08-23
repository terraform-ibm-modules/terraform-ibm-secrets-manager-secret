##############################################################################
# Secrets Manager Secret
#
# Creates Secret within existing Secret Manager instance and Secret Manager Group
##############################################################################

# Validation
# Approach based on https://stackoverflow.com/a/66682419
locals {
  # validate username_password or arbitrary secret has a password payload
  userpass_validate_condition = var.secret_type != "imported_cert" && var.secret_payload_password == "" #checkov:skip=CKV_SECRET_6
  userpass_validate_msg       = "When creating a username_password or arbitrary secret, a value for `secret_payload_password` is required."
  # tflint-ignore: terraform_unused_declarations
  userpass_validate_check = regex("^${local.userpass_validate_msg}$", (!local.userpass_validate_condition ? local.userpass_validate_msg : ""))

  # validate auto rotation
  auto_rotation_validate_condition = var.secret_user_pass_auto_rotation == true && var.secret_user_pass_auto_rotation_unit != "month" && var.secret_user_pass_auto_rotation == true && var.secret_user_pass_auto_rotation_unit != "day" || var.secret_user_pass_auto_rotation == true && var.secret_user_pass_auto_rotation_interval == 0
  auto_rotation_validate_msg       = "Value for `secret_user_pass_auto_rotation_unit' must be either `day` or `month` and value for `secret_user_pass_auto_rotation_interval` must be higher than 0"
  # tflint-ignore: terraform_unused_declarations
  auto_rotation_validate_check = regex("^${local.auto_rotation_validate_msg}$", (!local.auto_rotation_validate_condition ? local.auto_rotation_validate_msg : ""))

  # validate imported certificate has a TLS certificate
  imported_cert_validate_condition = var.secret_type == "imported_cert" && var.imported_cert_certificate == null #checkov:skip=CKV_SECRET_6
  imported_cert_validate_msg       = "When creating an imported_cert secret, value for `imported_cert_certificate` cannot be null."
  # tflint-ignore: terraform_unused_declarations
  imported_cert_validate_check = regex("^${local.imported_cert_validate_msg}$", (!local.imported_cert_validate_condition ? local.imported_cert_validate_msg : ""))

  auto_rotation_enabled = var.secret_user_pass_auto_rotation == true ? [1] : []
}

resource "ibm_sm_arbitrary_secret" "arbitrary_secret" {
  count           = var.secret_type == "arbitrary" ? 1 : 0
  region          = var.region
  instance_id     = var.secrets_manager_guid
  secret_group_id = var.secret_group_id
  name            = var.secret_name
  description     = var.secret_description
  labels          = var.secret_labels
  payload         = var.secret_payload_password
}

resource "ibm_sm_username_password_secret" "username_password_secret" {
  count           = var.secret_type == "username_password" ? 1 : 0 #checkov:skip=CKV_SECRET_6
  region          = var.region
  instance_id     = var.secrets_manager_guid
  secret_group_id = var.secret_group_id
  name            = var.secret_name
  description     = var.secret_description
  labels          = var.secret_labels
  username        = var.secret_username
  password        = var.secret_payload_password

  ## This for_each block is NOT a loop to attach to multiple rotation blocks.
  ## This block is only used to conditionally add rotation block depending on var.sm_iam_secret_auto_rotation
  dynamic "rotation" {
    for_each = local.auto_rotation_enabled
    content {
      auto_rotate = var.secret_user_pass_auto_rotation
      interval    = var.secret_user_pass_auto_rotation_interval
      unit        = var.secret_user_pass_auto_rotation_unit
    }
  }
}

locals {
  # There is a provider bug generating "module-metadata.json" where variable value is not access directly.
  # https://github.com/IBM-Cloud/terraform-config-inspect/issues/19
  imported_cert_certificate  = var.imported_cert_certificate != null ? trimspace(var.imported_cert_certificate) : null
  imported_cert_private_key  = var.imported_cert_private_key != null ? trimspace(var.imported_cert_private_key) : null
  imported_cert_intermediate = var.imported_cert_intermediate != null ? trimspace(var.imported_cert_intermediate) : null
}

resource "ibm_sm_imported_certificate" "imported_cert" {
  count           = var.secret_type == "imported_cert" ? 1 : 0
  region          = var.region
  instance_id     = var.secrets_manager_guid
  secret_group_id = var.secret_group_id
  name            = var.secret_name
  description     = var.secret_description
  labels          = var.secret_labels
  certificate     = local.imported_cert_certificate
  private_key     = local.imported_cert_private_key
  intermediate    = local.imported_cert_intermediate
}

# Parse secret ID and generate data header for secrets
locals {
  secret_id  = var.secret_type == "imported_cert" ? ibm_sm_imported_certificate.imported_cert[0].secret_id : var.secret_username == null ? ibm_sm_arbitrary_secret.arbitrary_secret[0].secret_id : ibm_sm_username_password_secret.username_password_secret[0].secret_id
  secret_crn = var.secret_type == "imported_cert" ? ibm_sm_imported_certificate.imported_cert[0].crn : var.secret_username == null ? ibm_sm_arbitrary_secret.arbitrary_secret[0].crn : ibm_sm_username_password_secret.username_password_secret[0].crn
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  username_password_secret_auto_rotation_suffix    = var.secret_user_pass_auto_rotation_interval > 1 ? "${var.secret_user_pass_auto_rotation_unit}s" : var.secret_user_pass_auto_rotation_unit
  username_password_secret_auto_rotation_frecuency = var.secret_user_pass_auto_rotation == true && var.secret_username != null ? "${var.secret_user_pass_auto_rotation_interval} ${local.username_password_secret_auto_rotation_suffix}" : null #tfsec:ignore:general-secrets-no-plaintext-exposure
  username_password_secret_next_rotation_date      = var.secret_user_pass_auto_rotation == true && var.secret_username != null ? ibm_sm_username_password_secret.username_password_secret[0].next_rotation_date : null
  secret_user_pass_auto_rotation                   = var.secret_username != null ? var.secret_user_pass_auto_rotation : null
}
