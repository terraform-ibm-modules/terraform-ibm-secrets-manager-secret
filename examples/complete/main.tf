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

  sm_guid   = var.existing_sm_instance_guid == null ? ibm_resource_instance.secrets_manager[0].guid : var.existing_sm_instance_guid
  sm_region = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region

  secret_labels = [var.prefix, var.region]
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Secrets Manager
##############################################################################

resource "ibm_resource_instance" "secrets_manager" {
  count             = var.existing_sm_instance_guid == null ? 1 : 0
  name              = "${var.prefix}-sm-instance"
  service           = "secrets-manager"
  plan              = var.sm_service_plan
  location          = var.region
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
}

##############################################################################
# Secret Group
##############################################################################

module "secrets_manager_group" {
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.0.1"
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

# retrieving information about the arbitrary secret
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
  source                         = "../.."
  region                         = local.sm_region
  secrets_manager_guid           = local.sm_guid
  secret_group_id                = module.secrets_manager_group.secret_group_id
  secret_name                    = "${var.prefix}-user-pass-no-rotate-secret"
  secret_description             = "created by secrets-manager-secret-module complete example"
  secret_type                    = "username_password" #checkov:skip=CKV_SECRET_6
  secret_payload_password        = local.payload
  secret_username                = "terraform-user" #checkov:skip=CKV_SECRET_6
  secret_labels                  = local.secret_labels
  secret_user_pass_auto_rotation = false
}

# retrieving information about the arbitrary secret
data "ibm_sm_username_password_secret" "user_pass_no_rotate_secret" {
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = module.secrets_manager_user_pass_no_rotate_secret.secret_id
}

##############################################################################
# Example working with imported cert secret
##############################################################################

# create imported cert secret
module "secret_manager_imported_cert" {
  source               = "../.."
  region               = local.sm_region
  secrets_manager_guid = local.sm_guid
  secret_name          = "${var.prefix}-imported-cert"
  secret_group_id      = module.secrets_manager_group.secret_group_id
  secret_description   = "created by secrets-manager-secret-module complete example"
  secret_type          = "imported_cert" #checkov:skip=CKV_SECRET_6
}
