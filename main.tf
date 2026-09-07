##############################################################################
# Secrets Manager Secret
#
# Creates Secret within existing Secret Manager instance and Secret Manager Group
##############################################################################

locals {
  auto_rotation_enabled = var.secret_auto_rotation == true ? [1] : []
  parameters_enabled    = var.custom_credentials_parameters == true ? [1] : []
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
  endpoint_type   = var.endpoint_type
  custom_metadata = var.custom_metadata
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
  endpoint_type   = var.endpoint_type
  custom_metadata = var.custom_metadata

  ## This for_each block is NOT a loop to attach to multiple rotation blocks.
  ## This block is only used to conditionally add rotation block depending on var.sm_iam_secret_auto_rotation
  dynamic "rotation" {
    for_each = local.auto_rotation_enabled
    content {
      auto_rotate = var.secret_auto_rotation
      interval    = var.secret_auto_rotation_interval
      unit        = var.secret_auto_rotation_unit
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
  count                   = var.secret_type == "imported_cert" ? 1 : 0 #checkov:skip=CKV_SECRET_6
  region                  = var.region
  instance_id             = var.secrets_manager_guid
  secret_group_id         = var.secret_group_id
  name                    = var.secret_name
  description             = var.secret_description
  labels                  = var.secret_labels
  certificate             = local.imported_cert_certificate
  private_key             = local.imported_cert_private_key
  intermediate            = local.imported_cert_intermediate
  endpoint_type           = var.endpoint_type
  custom_metadata         = var.custom_metadata
  version_custom_metadata = var.imported_cert_version_custom_metadata

  ## This dynamic block is only emitted when managed_csr is provided.
  ## When set, IBM Secrets Manager generates the private key and CSR internally.
  ## Follows the same conditional pattern used for the rotation block above.
  dynamic "managed_csr" {
    for_each = var.imported_cert_managed_csr != null ? [1] : []
    content {
      key_type              = var.imported_cert_managed_csr.key_type
      key_bits              = var.imported_cert_managed_csr.key_bits
      common_name           = var.imported_cert_managed_csr.common_name
      country               = var.imported_cert_managed_csr.country
      locality              = var.imported_cert_managed_csr.locality
      organization          = var.imported_cert_managed_csr.organization
      ou                    = var.imported_cert_managed_csr.ou
      postal_code           = var.imported_cert_managed_csr.postal_code
      province              = var.imported_cert_managed_csr.province
      street_address        = var.imported_cert_managed_csr.street_address
      alt_names             = var.imported_cert_managed_csr.alt_names
      ip_sans               = var.imported_cert_managed_csr.ip_sans
      uri_sans              = var.imported_cert_managed_csr.uri_sans
      other_sans            = var.imported_cert_managed_csr.other_sans
      user_ids              = var.imported_cert_managed_csr.user_ids
      key_usage             = var.imported_cert_managed_csr.key_usage
      ext_key_usage         = var.imported_cert_managed_csr.ext_key_usage
      ext_key_usage_oids    = var.imported_cert_managed_csr.ext_key_usage_oids
      policy_identifiers    = var.imported_cert_managed_csr.policy_identifiers
      client_flag           = var.imported_cert_managed_csr.client_flag
      code_signing_flag     = var.imported_cert_managed_csr.code_signing_flag
      email_protection_flag = var.imported_cert_managed_csr.email_protection_flag
      server_flag           = var.imported_cert_managed_csr.server_flag
      exclude_cn_from_sans  = var.imported_cert_managed_csr.exclude_cn_from_sans
      require_cn            = var.imported_cert_managed_csr.require_cn
      rotate_keys           = var.imported_cert_managed_csr.rotate_keys
    }
  }
}

locals {
  # there is a known issue with ternaries in merge, moved them out: https://github.com/hashicorp/terraform/issues/33310
  local_service_credentials_source_service_hmac = var.service_credentials_source_service_hmac ? { "HMAC" : var.service_credentials_source_service_hmac } : null
  local_service_credentials_serviceid_crn       = var.service_credentials_existing_serviceid_crn != null ? { "serviceid_crn" : var.service_credentials_existing_serviceid_crn } : null
  parameters = (
    var.service_credentials_parameters != null ? var.service_credentials_parameters :
    merge(
      local.local_service_credentials_source_service_hmac,
      local.local_service_credentials_serviceid_crn,
    )
  )
}

resource "ibm_sm_service_credentials_secret" "service_credentials_secret" {
  count           = var.secret_type == "service_credentials" ? 1 : 0 #checkov:skip=CKV_SECRET_6
  region          = var.region
  instance_id     = var.secrets_manager_guid
  secret_group_id = var.secret_group_id
  name            = var.secret_name
  description     = var.secret_description
  labels          = var.secret_labels
  ttl             = var.service_credentials_ttl
  endpoint_type   = var.endpoint_type
  custom_metadata = var.custom_metadata

  source_service {
    instance {
      crn = var.service_credentials_source_service_crn
    }
    role {
      crn = var.service_credentials_source_service_role_crn
    }
    parameters = local.parameters
  }

  ## This for_each block is NOT a loop to attach to multiple rotation blocks.
  ## This block is only used to conditionally add rotation block depending on var.sm_iam_secret_auto_rotation
  dynamic "rotation" {
    for_each = local.auto_rotation_enabled
    content {
      auto_rotate = var.secret_auto_rotation
      interval    = var.secret_auto_rotation_interval
      unit        = var.secret_auto_rotation_unit
    }
  }
}

resource "ibm_sm_kv_secret" "kv_secret" {
  count           = var.secret_type == "key_value" ? 1 : 0
  region          = var.region
  instance_id     = var.secrets_manager_guid
  secret_group_id = var.secret_group_id
  name            = var.secret_name
  description     = var.secret_description
  labels          = var.secret_labels
  data            = var.secret_kv_data
  endpoint_type   = var.endpoint_type
  custom_metadata = var.custom_metadata
}

resource "ibm_sm_custom_credentials_secret" "custom_credentials_secret" {
  count           = var.secret_type == "custom_credentials" ? 1 : 0 #checkov:skip=CKV_SECRET_6
  instance_id     = var.secrets_manager_guid
  region          = var.region
  name            = var.secret_name
  endpoint_type   = var.endpoint_type
  secret_group_id = var.secret_group_id
  custom_metadata = var.custom_metadata
  description     = var.secret_description
  labels          = var.secret_labels
  configuration   = var.custom_credentials_configurations
  dynamic "parameters" {
    for_each = local.parameters_enabled
    content {
      integer_values = var.job_parameters.integer_values
      string_values  = var.job_parameters.string_values
      boolean_values = var.job_parameters.boolean_values
    }
  }
  dynamic "rotation" {
    for_each = local.auto_rotation_enabled
    content {
      auto_rotate = var.secret_auto_rotation
      interval    = var.secret_auto_rotation_interval
      unit        = var.secret_auto_rotation_unit
    }
  }
  ttl = var.service_credentials_ttl
}

# Parse secret ID and generate data header for secrets
locals {
  secret_id = (
    var.secret_type == "username_password" ? ibm_sm_username_password_secret.username_password_secret[0].secret_id :
    var.secret_type == "imported_cert" ? ibm_sm_imported_certificate.imported_cert[0].secret_id :
    var.secret_type == "service_credentials" ? ibm_sm_service_credentials_secret.service_credentials_secret[0].secret_id :
    var.secret_type == "arbitrary" ? ibm_sm_arbitrary_secret.arbitrary_secret[0].secret_id :
    var.secret_type == "key_value" ? ibm_sm_kv_secret.kv_secret[0].secret_id :
    var.secret_type == "custom_credentials" ? ibm_sm_custom_credentials_secret.custom_credentials_secret[0].secret_id : null
  )
  secret_crn = (
    var.secret_type == "username_password" ? ibm_sm_username_password_secret.username_password_secret[0].crn :
    var.secret_type == "imported_cert" ? ibm_sm_imported_certificate.imported_cert[0].crn :
    var.secret_type == "service_credentials" ? ibm_sm_service_credentials_secret.service_credentials_secret[0].crn :
    var.secret_type == "arbitrary" ? ibm_sm_arbitrary_secret.arbitrary_secret[0].crn :
    var.secret_type == "key_value" ? ibm_sm_kv_secret.kv_secret[0].crn :
    var.secret_type == "custom_credentials" ? ibm_sm_custom_credentials_secret.custom_credentials_secret[0].crn : null
  )
  #tfsec:ignore:general-secrets-no-plaintext-exposure
  secret_auto_rotation_frequency = var.secret_auto_rotation == true ? "${var.secret_auto_rotation_interval} ${var.secret_auto_rotation_unit}(s)" : null #tfsec:ignore:general-secrets-no-plaintext-exposure
  secret_next_rotation_date = (
    var.secret_auto_rotation == true ?
    var.secret_type == "username_password" ? ibm_sm_username_password_secret.username_password_secret[0].next_rotation_date :
    var.secret_type == "service_credentials" ? ibm_sm_service_credentials_secret.service_credentials_secret[0].next_rotation_date :
    var.secret_type == "custom_credentials" ? ibm_sm_custom_credentials_secret.custom_credentials_secret[0].next_rotation_date : null : null
  )
  secret_auto_rotation = (var.secret_type == "username_password" || var.secret_type == "service_credentials") ? var.secret_auto_rotation : null
}
