# Secrets Manager Secret module

[![Stable (Adopted)](https://img.shields.io/badge/Status-Stable%20(Adopted)-yellowgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-secret?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret/releases/latest)

This module creates a secret in an IBM Secrets Manager secrets group.

The module supports the following secret types:

- [Arbitrary](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-arbitrary-secrets&interface=ui)
- [User credentials](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-user-credentials&interface=ui)
- [Imported Certificate](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-certificates&interface=api#import-certificates)

The following attributes and parameters are supported for both secret types:

- `secret_group_id`: When `null`, the `default` secret-group is used.
- `secret_name`: The name of the secret that is created.
- `secret_description`: The description of the secret.
- `secret_payload_password`: The payload (for arbitrary secrets) or password (for username and password credentials) of the secret.

The following attributes and parameters are supported only when storing user credentials:

- `secret_username`: The username of the secret that is created. Applicable only to the `username_password` secret type. When the parameter is `null`, an `arbitrary` secret is created.
- `secret_user_pass_auto_rotation`: Configures automatic rotation. Default is `true`.
- `secret_user_pass_auto_rotation_unit`: Specifies the unit type for the secret rotation. Accepted values are `day` or `month`. Default is `day`.
- `secret_user_pass_auto_rotation_interval`: Specifies the rotation interval for the rotation unit. Default is `90`.

The following attributes and parameters are supported only when creating imported certificates:

- `imported_cert`: specify if imported certificate secret type will be created, defaults to `false`.
- `imported_cert_certificate`: The TLS certificate to be imported. Defaults to `null`.
- `imported_cert_private_key`: Optional private key for the TLS certificate to be imported. Defaults to `null`.
- `imported_cert_intermediate`: Optional intermediate certificate for the TLS certificate to be imported. Defaults to `null`.

## Usage

```hcl
##############################################################################
# Create Arbitrary Secret
##############################################################################

module "secrets_manager_arbitrary_secret" {
  # Replace "master" with a GIT release version to lock into a specific release
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "3.1.1"
  region                  = "us-south"
  secrets_manager_guid    = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id         = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name             = "example-arbitrary-secret"
  secret_description      = "Extended description for the arbirtary secret."
  secret_payload_password = "secret-data" #pragma: allowlist secret
}
```

```hcl
##############################################################################
# Create UserPass Secret
##############################################################################

module "secrets_manager_user_pass_secret" {
  # Replace "master" with a GIT release version to lock into a specific release
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "3.1.1"
  region                  = "us-south"
  secrets_manager_guid    = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id         = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name             = "example-user-pass-secret"
  secret_description      = "Extended description for the user pass secret."
  secret_payload_password = "secret-data" #pragma: allowlist secret
  secret_username         = "terraform-user"
}
```

```hcl
##############################################################################
# Create Imported Cert
##############################################################################

module "secret_manager_imported_cert secret" {
  # Replace "master" with a GIT release version to lock into a specific release
  source                     = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                    = "3.1.1"
  region                     = "us-south
  secrets_manager_guid       = "42454b3b-5b06-407b-a4b3-34d9ef323901"
  secret_group_id            = "432b91f1-ff6d-4b47-9f06-82debc236d90"
  secret_name                = "example-imported-cert-secret"
  secret_description         = "Extended description for the imported cert secret."
  imported_cert              = true
  imported_cert_certificate  = module.certificate.cert_pem
  imported_cert_private_key  = module.certificate.private_key #pragma: allowlist secret
  imported_cert_intermediate = module.certificate.ca_cert_pem
}
```

## Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Secrets Manager** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Example creating arbitrary, username_password and imported_cert type secrets](examples/complete)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_sm_arbitrary_secret.arbitrary_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_arbitrary_secret) | resource |
| [ibm_sm_imported_certificate.imported_cert](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_imported_certificate) | resource |
| [ibm_sm_username_password_secret.username_password_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_username_password_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_imported_cert_certificate"></a> [imported\_cert\_certificate](#input\_imported\_cert\_certificate) | The TLS certificate to import. | `string` | `null` | no |
| <a name="input_imported_cert_intermediate"></a> [imported\_cert\_intermediate](#input\_imported\_cert\_intermediate) | (optional) The intermediate certificate for the TLS certificate to import. | `string` | `null` | no |
| <a name="input_imported_cert_private_key"></a> [imported\_cert\_private\_key](#input\_imported\_cert\_private\_key) | (optional) The private key for the TLS certificate to import. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the Secrets Manager instance is deployed. | `string` | n/a | yes |
| <a name="input_secret_description"></a> [secret\_description](#input\_secret\_description) | Description of the secret to create. | `string` | n/a | yes |
| <a name="input_secret_group_id"></a> [secret\_group\_id](#input\_secret\_group\_id) | The ID of the secret group for the secret. If `null`, the `default` secret group is used. | `string` | `"default"` | no |
| <a name="input_secret_labels"></a> [secret\_labels](#input\_secret\_labels) | Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (\|). | `list(string)` | `[]` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the secret to create. | `string` | n/a | yes |
| <a name="input_secret_payload_password"></a> [secret\_payload\_password](#input\_secret\_payload\_password) | The payload (for arbitrary secrets) or password (for username and password credentials) of the secret. | `string` | `""` | no |
| <a name="input_secret_type"></a> [secret\_type](#input\_secret\_type) | Type of secret to create, must be one of: arbitrary, username\_password, imported\_cert | `string` | n/a | yes |
| <a name="input_secret_user_pass_auto_rotation"></a> [secret\_user\_pass\_auto\_rotation](#input\_secret\_user\_pass\_auto\_rotation) | Whether to configure automatic rotation. Applies only to the `username_password` secret type. | `bool` | `true` | no |
| <a name="input_secret_user_pass_auto_rotation_interval"></a> [secret\_user\_pass\_auto\_rotation\_interval](#input\_secret\_user\_pass\_auto\_rotation\_interval) | Specifies the rotation interval for the rotation unit. | `number` | `90` | no |
| <a name="input_secret_user_pass_auto_rotation_unit"></a> [secret\_user\_pass\_auto\_rotation\_unit](#input\_secret\_user\_pass\_auto\_rotation\_unit) | Specifies the unit of time for rotation of a username\_password secret. Acceptable values are `day` or `month`. | `string` | `"day"` | no |
| <a name="input_secret_username"></a> [secret\_username](#input\_secret\_username) | Username of the secret to create. Applies only to `username_password` secret types. When `null`, an `arbitrary` secret is created. | `string` | `null` | no |
| <a name="input_secrets_manager_guid"></a> [secrets\_manager\_guid](#input\_secrets\_manager\_guid) | The instance ID of the Secrets Manager instance where the secret will be added. | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private` | `string` | `"public"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_crn"></a> [secret\_crn](#output\_secret\_crn) | CRN of the created Secret |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | ID of the created Secret |
| <a name="output_user_pass_next_rotation_date"></a> [user\_pass\_next\_rotation\_date](#output\_user\_pass\_next\_rotation\_date) | Next rotation data for username\_password secret |
| <a name="output_user_pass_rotation"></a> [user\_pass\_rotation](#output\_user\_pass\_rotation) | Status of auto-rotation for username\_password secret |
| <a name="output_user_pass_rotation_interval"></a> [user\_pass\_rotation\_interval](#output\_user\_pass\_rotation\_interval) | Rotation frecuency for username\_password secret |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
