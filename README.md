# Secrets Manager Secret module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-secret?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret/releases/latest)

This module creates a secret in an IBM Secrets Manager secrets group.

The module supports the following secret types:

- [Arbitrary](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-arbitrary-secrets&interface=ui)
- [User credentials](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-user-credentials&interface=ui)
- [Imported Certificate](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-certificates&interface=api#import-certificates)
- [Service Credentials](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-service-credentials&interface=api)

The following attributes and parameters are supported for all secret types:

- `secret_group_id`: When `null`, the `default` secret-group is used.
- `secret_name`: The name of the secret that is created.
- `secret_description`: The description of the secret.
- `secret_type` : The type of the secret.
- `secret_labels` : Any labels to attach to the secret.

The following attributes and paramters are supported when storing arbitrary secrets:

- `secret_payload_password`: The payload (for arbitrary secrets) or password (for username and password credentials) of the secret.

The following attributes and parameters are supported when storing user credentials:

- `secret_payload_password`: The payload (for arbitrary secrets) or password (for username and password credentials) of the secret.
- `secret_username`: The username of the secret that is created. Applicable only to the `username_password` secret type. When the parameter is `null`, an `arbitrary` secret is created.
- `secret_auto_rotation`: Configures automatic rotation. Default is `true`.
- `secret_auto_rotation_unit`: Specifies the unit type for the secret rotation. Accepted values are `day` or `month`. Default is `day`.
- `secret_auto_rotation_interval`: Specifies the rotation interval for the rotation unit. Default is `89`.

The following attributes and parameters are supported when creating imported certificates:

- `imported_cert_certificate`: The TLS certificate to be imported. Defaults to `null`.
- `imported_cert_private_key`: Optional private key for the TLS certificate to be imported. Defaults to `null`.
- `imported_cert_intermediate`: Optional intermediate certificate for the TLS certificate to be imported. Defaults to `null`.

The following attributes and parameters are supported when creating service credentials:

- `service_credentials_source_service_crn`: The CRN of the target service instance to create the service credentials.
- `service_credentials_source_service_role`: The service specific role to give the service credentials.
- `secret_auto_rotation`: Configures automatic rotation. Default is `true`.
- `secret_auto_rotation_unit`: Specifies the unit type for the secret rotation. Accepted values are `day` or `month`. Default is `day`.
- `secret_auto_rotation_interval`: Specifies the rotation interval for the rotation unit. Default is `89`.

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-secrets-manager-secret](#terraform-ibm-secrets-manager-secret)
* [Examples](./examples)
    * [Example creating arbitrary, username_password and imported_cert type secrets](./examples/complete)
    * [Private-Only Secret Manager example](./examples/private)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-secrets-manager-secret
### Usage

```hcl
##############################################################################
# Create Arbitrary Secret
##############################################################################

module "secrets_manager_arbitrary_secret" {
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "latest" # Replace "latest" with a release version to lock into a specific release
  region                  = "us-south"
  secrets_manager_guid    = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id         = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name             = "example-arbitrary-secret"
  secret_description      = "Extended description for the arbirtary secret."
  secret_type             = "arbitrary"
  secret_payload_password = "secret-data" #pragma: allowlist secret
}
```

```hcl
##############################################################################
# Create UserPass Secret
##############################################################################

module "secrets_manager_user_pass_secret" {
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "latest" # Replace "latest" with a release version to lock into a specific release
  region                  = "us-south"
  secrets_manager_guid    = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id         = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name             = "example-user-pass-secret"
  secret_description      = "Extended description for the user pass secret."
  secret_type             = "username_password"
  secret_payload_password = "secret-data" #pragma: allowlist secret
  secret_username         = "terraform-user"
}
```

```hcl
##############################################################################
# Create Imported Cert
##############################################################################

module "secret_manager_imported_cert secret" {
  source                     = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                    = "latest" # Replace "latest" with a release version to lock into a specific release
  region                     = "us-south
  secrets_manager_guid       = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id            = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name                = "example-imported-cert-secret"
  secret_description         = "Extended description for the imported cert secret."
  secret_type                = "imported_cert"
  imported_cert_certificate  = module.certificate.cert_pem
  imported_cert_private_key  = module.certificate.private_key #pragma: allowlist secret
  imported_cert_intermediate = module.certificate.ca_cert_pem
}
```

```hcl
##############################################################################
# Create Service Credentials
##############################################################################

# A service authorization between Secrets Manager and the target service is required. The "complete" example includes a sample service authorization.

module "secret_manager_service_credential" {
  source                                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                                 = "latest" # Replace "latest" with a release version to lock into a specific release
  region                                  = "us-south
  secrets_manager_guid                    = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id                         = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name                             = "example-service-credential"
  secret_description                      = "Extended description for the service credentials secret."
  secret_type                             = "service_credentials"
  service_credentials_source_service_crn  = module.cloud_object_storage.cos_instance_id
  service_credentials_source_service_role = "Writer"
}
```

### Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Secrets Manager** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_sm_arbitrary_secret.arbitrary_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_arbitrary_secret) | resource |
| [ibm_sm_imported_certificate.imported_cert](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_imported_certificate) | resource |
| [ibm_sm_service_credentials_secret.service_credentials_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_service_credentials_secret) | resource |
| [ibm_sm_username_password_secret.username_password_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_username_password_secret) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_metadata"></a> [custom\_metadata](#input\_custom\_metadata) | Optional metadata to be added to the secret. | `map(string)` | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private` | `string` | `"public"` | no |
| <a name="input_imported_cert_certificate"></a> [imported\_cert\_certificate](#input\_imported\_cert\_certificate) | The TLS certificate to import. | `string` | `null` | no |
| <a name="input_imported_cert_intermediate"></a> [imported\_cert\_intermediate](#input\_imported\_cert\_intermediate) | (optional) The intermediate certificate for the TLS certificate to import. | `string` | `null` | no |
| <a name="input_imported_cert_private_key"></a> [imported\_cert\_private\_key](#input\_imported\_cert\_private\_key) | (optional) The private key for the TLS certificate to import. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the Secrets Manager instance is deployed. | `string` | n/a | yes |
| <a name="input_secret_auto_rotation"></a> [secret\_auto\_rotation](#input\_secret\_auto\_rotation) | Whether to configure automatic rotation. Applies only to the `username_password` and `service_credentials` secret types. | `bool` | `true` | no |
| <a name="input_secret_auto_rotation_interval"></a> [secret\_auto\_rotation\_interval](#input\_secret\_auto\_rotation\_interval) | Specifies the rotation interval for the rotation unit. | `number` | `89` | no |
| <a name="input_secret_auto_rotation_unit"></a> [secret\_auto\_rotation\_unit](#input\_secret\_auto\_rotation\_unit) | Specifies the unit of time for rotation of a username\_password secret. Acceptable values are `day` or `month`. | `string` | `"day"` | no |
| <a name="input_secret_description"></a> [secret\_description](#input\_secret\_description) | Description of the secret to create. | `string` | n/a | yes |
| <a name="input_secret_group_id"></a> [secret\_group\_id](#input\_secret\_group\_id) | The ID of the secret group for the secret. If `null`, the `default` secret group is used. | `string` | `"default"` | no |
| <a name="input_secret_labels"></a> [secret\_labels](#input\_secret\_labels) | Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (\|). | `list(string)` | `[]` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the secret to create. | `string` | n/a | yes |
| <a name="input_secret_payload_password"></a> [secret\_payload\_password](#input\_secret\_payload\_password) | The payload (for arbitrary secrets) or password (for username and password credentials) of the secret. | `string` | `""` | no |
| <a name="input_secret_type"></a> [secret\_type](#input\_secret\_type) | Type of secret to create, must be one of: arbitrary, username\_password, imported\_cert, service\_credentials | `string` | n/a | yes |
| <a name="input_secret_username"></a> [secret\_username](#input\_secret\_username) | Username of the secret to create. Applies only to `username_password` secret types. When `null`, an `arbitrary` secret is created. | `string` | `null` | no |
| <a name="input_secrets_manager_guid"></a> [secrets\_manager\_guid](#input\_secrets\_manager\_guid) | The instance ID of the Secrets Manager instance where the secret will be added. | `string` | n/a | yes |
| <a name="input_service_credentials_existing_serviceid_crn"></a> [service\_credentials\_existing\_serviceid\_crn](#input\_service\_credentials\_existing\_serviceid\_crn) | The optional parameter 'serviceid\_crn' for creating service credentials. If not passed in, a new Service ID will be created. For more information see https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_service_credentials_secret#parameters | `string` | `null` | no |
| <a name="input_service_credentials_parameters"></a> [service\_credentials\_parameters](#input\_service\_credentials\_parameters) | List of all custom parameters for service credential. | `map(string)` | `null` | no |
| <a name="input_service_credentials_source_service_crn"></a> [service\_credentials\_source\_service\_crn](#input\_service\_credentials\_source\_service\_crn) | The CRN of the source service instance to create the service credential. | `string` | `null` | no |
| <a name="input_service_credentials_source_service_hmac"></a> [service\_credentials\_source\_service\_hmac](#input\_service\_credentials\_source\_service\_hmac) | The optional boolean parameter 'HMAC' for creating specific kind of credentials. For more information see https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_service_credentials_secret#parameters | `bool` | `false` | no |
| <a name="input_service_credentials_source_service_role_crn"></a> [service\_credentials\_source\_service\_role\_crn](#input\_service\_credentials\_source\_service\_role\_crn) | The CRN for the role to give the service credential in the source service. See https://cloud.ibm.com/iam/roles | `string` | `null` | no |
| <a name="input_service_credentials_ttl"></a> [service\_credentials\_ttl](#input\_service\_credentials\_ttl) | The time-to-live (TTL) to assign to generated service credentials (in seconds). | `number` | `"7776000"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_crn"></a> [secret\_crn](#output\_secret\_crn) | CRN of the created Secret |
| <a name="output_secret_group_id"></a> [secret\_group\_id](#output\_secret\_group\_id) | Secret group ID of the created secret |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | ID of the created Secret |
| <a name="output_secret_next_rotation_date"></a> [secret\_next\_rotation\_date](#output\_secret\_next\_rotation\_date) | Next rotation date for secret (if applicable) |
| <a name="output_secret_rotation"></a> [secret\_rotation](#output\_secret\_rotation) | Status of auto-rotation for secret |
| <a name="output_secret_rotation_interval"></a> [secret\_rotation\_interval](#output\_secret\_rotation\_interval) | Rotation frecuency for secret (if applicable) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
