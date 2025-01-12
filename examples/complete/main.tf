##############################################################################
# Local variables + validation
##############################################################################

locals {
  payload                = sensitive("secret-payload-example")
  validate_sm_region_cnd = var.existing_sm_instance_guid != null && var.existing_sm_instance_region == null
  validate_sm_region_msg = "existing_sm_instance_region must also be set when value given for existing_sm_instance_guid."
  # tflint-ignore: terraform_unused_declarations
  validate_sm_region_chk = regex(
    "^${local.validate_sm_region_msg}$",
    (!local.validate_sm_region_cnd
      ? local.validate_sm_region_msg
  : ""))

  sm_guid   = var.existing_sm_instance_guid == null ? module.secrets_manager[0].secrets_manager_guid : var.existing_sm_instance_guid
  sm_region = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region

  secret_labels = [var.prefix, var.region]
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  count                = var.existing_sm_instance_guid == null ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "1.20.0"
  resource_group_id    = module.resource_group.resource_group_id
  region               = local.sm_region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = var.sm_service_plan
  allowed_network      = "public-and-private"
  sm_tags              = var.resource_tags
}

##############################################################################
# Secret Group
##############################################################################

module "secrets_manager_group" {
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.2.2"
  region                   = local.sm_region
  secrets_manager_guid     = local.sm_guid
  secret_group_name        = "${var.prefix}-group"
  secret_group_description = "created by secrets-manager-secret-module complete example"
}

##############################################################################
# Example working with arbitrary secret
##############################################################################

# create arbitrary secret
module "secrets_manager_arbitrary_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = local.sm_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-arbitrary-secret"
  secret_description      = "created by secrets-manager-secret-module complete example"
  secret_type             = "arbitrary" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_labels           = local.secret_labels
}

# retrieving information about the arbitrary secret
data "ibm_sm_arbitrary_secret" "arbitrary_secret" {
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = module.secrets_manager_arbitrary_secret.secret_id
}

##############################################################################
# Example working with username / password secret
##############################################################################

# create username / password secret
module "secrets_manager_user_pass_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = local.sm_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-user-pass-secret"
  secret_description      = "created by secrets-manager-secret-module complete example"
  secret_type             = "username_password" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_username         = "terraform-user" #checkov:skip=CKV_SECRET_6
  secret_labels           = local.secret_labels
}

# retrieving information about the userpass secret
data "ibm_sm_username_password_secret" "user_pass_secret" {
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = module.secrets_manager_user_pass_secret.secret_id
}

##############################################################################
# Example working with username / password secret (without password rotation)
##############################################################################

# create username / password secret
module "secrets_manager_user_pass_no_rotate_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = local.sm_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-user-pass-no-rotate-secret"
  secret_description      = "created by secrets-manager-secret-module complete example"
  secret_type             = "username_password" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_username         = "terraform-user" #checkov:skip=CKV_SECRET_6
  secret_labels           = local.secret_labels
  secret_auto_rotation    = false
}

# retrieving information about the userpass secret
data "ibm_sm_username_password_secret" "user_pass_no_rotate_secret" {
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = module.secrets_manager_user_pass_no_rotate_secret.secret_id
}

##############################################################################
# Example working with imported cert secret
##############################################################################

resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
  is_ca_certificate = true
  private_key_pem   = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "goldeneye.com"
    organization = "GoldenEye self signed cert"
  }

  validity_period_hours = 1 * 24 * 90
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "tls_cert_request" "request" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "goldeneye.com"
    organization = "GoldenEye self signed cert"
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem   = tls_cert_request.request.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 1 * 24 * 90
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

# create imported cert secret
module "secret_manager_imported_cert" {
  source                     = "../.."
  region                     = local.sm_region
  secrets_manager_guid       = local.sm_guid
  secret_name                = "${var.prefix}-imported-cert"
  secret_group_id            = module.secrets_manager_group.secret_group_id
  secret_description         = "created by secrets-manager-secret-module complete example"
  secret_type                = "imported_cert" #checkov:skip=CKV_SECRET_6
  imported_cert_certificate  = resource.tls_locally_signed_cert.cert.cert_pem
  imported_cert_private_key  = resource.tls_private_key.key.private_key_pem
  imported_cert_intermediate = resource.tls_self_signed_cert.ca_cert.cert_pem
}

##############################################################################
# Example working with service credentials secret
##############################################################################

# create a COS instance to create the service credential for
module "cloud_object_storage" {
  source                             = "terraform-ibm-modules/cos/ibm"
  version                            = "8.16.5"
  resource_group_id                  = module.resource_group.resource_group_id
  region                             = var.region
  cos_instance_name                  = "${var.prefix}-cos"
  cos_tags                           = var.resource_tags
  bucket_name                        = "${var.prefix}-bucket"
  activity_tracker_read_data_events  = false
  activity_tracker_write_data_events = false
  request_metrics_enabled            = false
  retention_enabled                  = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled             = false
  usage_metrics_enabled              = false
}

#create a service authorization between Secrets Manager and the target service (COS)
resource "ibm_iam_authorization_policy" "policy" {
  depends_on                  = [module.cloud_object_storage]
  source_service_name         = "secrets-manager"
  source_resource_instance_id = local.sm_guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cloud_object_storage.cos_instance_guid
  roles                       = ["Key Manager"]
}

# create service credentials secret
module "secret_manager_service_credential" {
  depends_on                              = [ibm_iam_authorization_policy.policy]
  source                                  = "../.."
  region                                  = local.sm_region
  secrets_manager_guid                    = local.sm_guid
  secret_name                             = "${var.prefix}-service-credentials"
  secret_group_id                         = module.secrets_manager_group.secret_group_id
  secret_description                      = "created by secrets-manager-secret-module complete example"
  secret_type                             = "service_credentials" #checkov:skip=CKV_SECRET_6
  service_credentials_source_service_crn  = module.cloud_object_storage.cos_instance_id
  service_credentials_source_service_role = "Writer"
}
