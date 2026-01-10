##############################################################################
# Local variables
##############################################################################

locals {
  payload = sensitive("secret-payload-example")
  kv_data = { "key1" : "value", "key2" : true, "key3" : 4 }

  secret_labels = [var.prefix, var.region]
  sm_region     = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
}

##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  source                        = "terraform-ibm-modules/secrets-manager/ibm"
  version                       = "2.12.17"
  existing_sm_instance_crn      = var.existing_sm_instance_crn
  resource_group_id             = module.resource_group.resource_group_id
  region                        = local.sm_region
  secrets_manager_name          = "${var.prefix}-sm"
  sm_service_plan               = var.sm_service_plan
  allowed_network               = "private-only"
  endpoint_type                 = "private"
  sm_tags                       = var.resource_tags
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
}

##############################################################################
# Secret Group
##############################################################################

module "secrets_manager_group" {
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.36"
  region                   = local.sm_region
  secrets_manager_guid     = module.secrets_manager.secrets_manager_guid
  secret_group_name        = "${var.prefix}-group"
  secret_group_description = "created by secrets-manager-secret-module private example"
  endpoint_type            = "private"
}

##############################################################################
# Example working with arbitrary secret
##############################################################################

# create arbitrary secret
module "secrets_manager_arbitrary_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = module.secrets_manager.secrets_manager_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-arbitrary-secret"
  secret_description      = "created by secrets-manager-secret-module private example"
  secret_type             = "arbitrary" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_labels           = local.secret_labels
  endpoint_type           = "private"
}

# retrieving information about the arbitrary secret
data "ibm_sm_arbitrary_secret" "arbitrary_secret" {
  instance_id   = module.secrets_manager.secrets_manager_guid
  region        = local.sm_region
  secret_id     = module.secrets_manager_arbitrary_secret.secret_id
  endpoint_type = "private"
}

##############################################################################
# Example working with username / password secret
##############################################################################

# create username / password secret
module "secrets_manager_user_pass_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = module.secrets_manager.secrets_manager_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-user-pass-secret"
  secret_description      = "created by secrets-manager-secret-module private example"
  secret_type             = "username_password" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_username         = "terraform-user" #checkov:skip=CKV_SECRET_6
  secret_labels           = local.secret_labels
  endpoint_type           = "private"
}

# retrieving information about the userpass secret
data "ibm_sm_username_password_secret" "user_pass_secret" {
  instance_id   = module.secrets_manager.secrets_manager_guid
  region        = local.sm_region
  secret_id     = module.secrets_manager_user_pass_secret.secret_id
  endpoint_type = "private"
}

##############################################################################
# Example working with username / password secret (without password rotation)
##############################################################################

# create username / password secret
module "secrets_manager_user_pass_no_rotate_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = module.secrets_manager.secrets_manager_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-user-pass-no-rotate-secret"
  secret_description      = "created by secrets-manager-secret-module private example"
  secret_type             = "username_password" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
  secret_username         = "terraform-user" #checkov:skip=CKV_SECRET_6
  secret_labels           = local.secret_labels
  secret_auto_rotation    = false
  endpoint_type           = "private"
}

# retrieving information about the userpass secret
data "ibm_sm_username_password_secret" "user_pass_no_rotate_secret" {
  instance_id   = module.secrets_manager.secrets_manager_guid
  region        = local.sm_region
  secret_id     = module.secrets_manager_user_pass_no_rotate_secret.secret_id
  endpoint_type = "private"
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
  secrets_manager_guid       = module.secrets_manager.secrets_manager_guid
  secret_name                = "${var.prefix}-imported-cert"
  secret_group_id            = module.secrets_manager_group.secret_group_id
  secret_description         = "created by secrets-manager-secret-module private example"
  secret_type                = "imported_cert" #checkov:skip=CKV_SECRET_6
  imported_cert_certificate  = resource.tls_locally_signed_cert.cert.cert_pem
  imported_cert_private_key  = resource.tls_private_key.key.private_key_pem
  imported_cert_intermediate = resource.tls_self_signed_cert.ca_cert.cert_pem
  endpoint_type              = "private"
}

##############################################################################
# Example working with service credentials secret
##############################################################################

# create a COS instance to create the service credential for
module "cloud_object_storage" {
  source                              = "terraform-ibm-modules/cos/ibm"
  version                             = "10.8.3"
  resource_group_id                   = module.resource_group.resource_group_id
  region                              = local.sm_region
  cos_instance_name                   = "${var.prefix}-cos"
  cos_tags                            = var.resource_tags
  create_cos_bucket                   = false
  management_endpoint_type_for_bucket = "direct"
  activity_tracker_read_data_events   = false
  activity_tracker_write_data_events  = false
  request_metrics_enabled             = false
  retention_enabled                   = false # disable retention for test environments - enable for stage/prod
  kms_encryption_enabled              = false
  usage_metrics_enabled               = false
}

#create a service authorization between Secrets Manager and the target service (COS)
resource "ibm_iam_authorization_policy" "policy" {
  depends_on                  = [module.cloud_object_storage]
  source_service_name         = "secrets-manager"
  source_resource_instance_id = module.secrets_manager.secrets_manager_guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cloud_object_storage.cos_instance_guid
  roles                       = ["Key Manager"]
}

# create service credentials secret
module "secret_manager_service_credential" {
  depends_on                                  = [ibm_iam_authorization_policy.policy]
  source                                      = "../.."
  region                                      = local.sm_region
  secrets_manager_guid                        = module.secrets_manager.secrets_manager_guid
  secret_name                                 = "${var.prefix}-service-credentials"
  secret_group_id                             = module.secrets_manager_group.secret_group_id
  secret_description                          = "created by secrets-manager-secret-module private example"
  secret_type                                 = "service_credentials" #checkov:skip=CKV_SECRET_6
  service_credentials_source_service_crn      = module.cloud_object_storage.cos_instance_id
  service_credentials_source_service_role_crn = "crn:v1:bluemix:public:iam::::serviceRole:Writer"
  endpoint_type                               = "private"
}
##############################################################################
# Example working with key-value secret
##############################################################################

# create key-value secret
module "secrets_manager_key_value_secret" {
  source               = "../.."
  region               = local.sm_region
  secrets_manager_guid = module.secrets_manager.secrets_manager_guid
  secret_group_id      = module.secrets_manager_group.secret_group_id
  secret_name          = "${var.prefix}-key-value-secret"
  secret_description   = "created by secrets-manager-secret-module private example"
  secret_type          = "key_value"
  secret_kv_data       = local.kv_data
  secret_labels        = local.secret_labels
  endpoint_type        = "private"
}

# retrieving information about the key-value secret
data "ibm_sm_kv_secret" "kv_secret" {
  instance_id   = module.secrets_manager.secrets_manager_guid
  region        = local.sm_region
  secret_id     = module.secrets_manager_key_value_secret.secret_id
  endpoint_type = "private"
}

##############################################################################
# Example working with Custom Credential Engine
##############################################################################
##############################################################################
# Code Engine Project
##############################################################################
module "code_engine_project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.7.22"
  name              = "${var.prefix}-project"
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Secret
##############################################################################
module "code_engine_secret" {
  source     = "terraform-ibm-modules/code-engine/ibm//modules/secret"
  version    = "4.7.22"
  name       = "${var.prefix}-rs"
  project_id = module.code_engine_project.id
  format     = "registry"
  data = {
    "server"   = "private.uk.icr.io",
    "username" = "iamapikey",
    "password" = var.ibmcloud_api_key,
  }
}

##############################################################################
# Container Registry Namespace
##############################################################################
resource "ibm_cr_namespace" "rg_namespace" {
  name              = "${var.prefix}-crn"
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Build
##############################################################################
locals {
  output_image = "private.uk.icr.io/${resource.ibm_cr_namespace.rg_namespace.name}/custom-engine-job"
}

module "code_engine_build" {
  source                     = "terraform-ibm-modules/code-engine/ibm//modules/build"
  version                    = "4.7.22"
  name                       = "${var.prefix}-build"
  ibmcloud_api_key           = var.ibmcloud_api_key
  region                     = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
  project_id                 = module.code_engine_project.id
  existing_resource_group_id = module.resource_group.resource_group_id
  source_url                 = "https://github.com/IBM/secrets-manager-custom-credentials-providers"
  source_context_dir         = "ibmcloud-iam-user-apikey-provider-go"
  strategy_type              = "dockerfile"
  output_secret              = module.code_engine_secret.name
  output_image               = local.output_image
}

##############################################################################
# Code Engine Job
##############################################################################

data "http" "job_config" {
  url = "https://raw.githubusercontent.com/IBM/secrets-manager-custom-credentials-providers/refs/heads/main/ibmcloud-iam-user-apikey-provider-go/job_config.json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  job_env_variables = jsondecode(data.http.job_config.response_body).job_env_variables
}

module "code_engine_job" {
  source          = "terraform-ibm-modules/code-engine/ibm//modules/job"
  version         = "4.7.22"
  name            = "${var.prefix}-job"
  image_reference = local.output_image
  image_secret    = module.code_engine_secret.name
  project_id      = module.code_engine_project.id
  run_env_variables = [
    for env_var in local.job_env_variables : {
      type  = "literal"
      name  = env_var.name
      value = tostring(env_var.value)
    }
  ]
}

##############################################################################
# Custom Credential Engine and secret
##############################################################################

module "custom_credential_engine" {
  source                        = "terraform-ibm-modules/secrets-manager-custom-credentials-engine/ibm"
  version                       = "1.0.21"
  secrets_manager_guid          = module.secrets_manager.secrets_manager_guid
  secrets_manager_region        = local.sm_region
  custom_credential_engine_name = "${var.prefix}-test-custom-engine"
  endpoint_type                 = "private"
  code_engine_project_id        = module.code_engine_project.project_id
  code_engine_job_name          = module.code_engine_job.name
  code_engine_region            = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
  task_timeout                  = "10m"
  service_id_name               = "${var.prefix}-test-service-id"
  iam_credential_secret_name    = "${var.prefix}-test-iam-secret"
}

resource "ibm_iam_api_key" "api_key" {
  name        = "${var.prefix}-api-key"
  description = "created for secrets-manager-secret complete example"
}

module "secrets_manager_custom_arbitrary_secret" {
  source                  = "../.."
  region                  = local.sm_region
  secrets_manager_guid    = module.secrets_manager.secrets_manager_guid
  secret_group_id         = module.secrets_manager_group.secret_group_id
  secret_name             = "${var.prefix}-custom-arbitrary-secret"
  secret_description      = "created by secrets-manager-secret-module private example"
  secret_type             = "arbitrary" #checkov:skip=CKV_SECRET_6
  secret_payload_password = ibm_iam_api_key.api_key.apikey
  secret_labels           = local.secret_labels
  endpoint_type           = "private"
}

# create custom credentials secret
module "secret_manager_custom_credential" {
  depends_on                        = [module.custom_credential_engine]
  source                            = "../.."
  secret_type                       = "custom_credentials" #checkov:skip=CKV_SECRET_6
  region                            = local.sm_region
  secrets_manager_guid              = module.secrets_manager.secrets_manager_guid
  secret_name                       = "${var.prefix}-custom-credentials"
  secret_group_id                   = module.secrets_manager_group.secret_group_id
  secret_description                = "created by secrets-manager-secret-module private example"
  custom_credentials_configurations = module.custom_credential_engine.custom_config_engine_name
  custom_metadata                   = { "metadata_custom_key" : "metadata_custom_value" } # can add any custom metadata here
  custom_credentials_parameters     = true
  job_parameters = {
    string_values = {
      apikey_secret_id = module.secrets_manager_custom_arbitrary_secret.secret_id
    }
  }
  endpoint_type = "private"
}
