##############################################################################
# Input Variables
##############################################################################

variable "region" {
  type        = string
  description = "The region where the Secrets Manager instance is deployed."
}
variable "secrets_manager_guid" {
  type        = string
  description = "The instance ID of the Secrets Manager instance where the secret will be added."
}
variable "secret_group_id" {
  type        = string
  description = "The ID of the secret group for the secret. If `null`, the `default` secret group is used."
  default     = "default"
}
variable "secret_type" {
  type        = string
  description = "Type of secret to create, must be one of: arbitrary, username_password, imported_cert"
  validation {
    condition = anytrue([
      var.secret_type == "arbitrary",         #checkov:skip=CKV_SECRET_6
      var.secret_type == "username_password", #checkov:skip=CKV_SECRET_6
      var.secret_type == "imported_cert",     #checkov:skip=CKV_SECRET_6
    ])
    error_message = "Only supported secrets types are arbitrary, username_password, or imported_cert"
  }
}
variable "imported_cert_certificate" {
  type        = string
  description = "The TLS certificate to import."
  default     = null
}
variable "imported_cert_private_key" {
  type        = string
  description = "(optional) The private key for the TLS certificate to import."
  default     = null
  sensitive   = true
}
variable "imported_cert_intermediate" {
  type        = string
  description = "(optional) The intermediate certificate for the TLS certificate to import."
  default     = null
}
variable "secret_name" {
  type        = string
  description = "Name of the secret to create."
}
variable "secret_description" {
  type        = string
  description = "Description of the secret to create."
}
variable "secret_username" {
  type        = string
  description = "Username of the secret to create. Applies only to `username_password` secret types. When `null`, an `arbitrary` secret is created."
  default     = null
}
variable "secret_labels" {
  type        = list(string)
  description = "Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|)."
  default     = []

  validation {
    condition     = (length(var.secret_labels) <= 30) && (length(var.secret_labels) > 0 ? can([for label in var.secret_labels : regex("^[^<>,:&|]{2,30}$", label)]) : true)
    error_message = "Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|)."
  }
}
variable "secret_payload_password" {
  type        = string
  description = "The payload (for arbitrary secrets) or password (for username and password credentials) of the secret."
  sensitive   = true
  default     = "" #tfsec:ignore:general-secrets-no-plaintext-exposure
}
variable "secret_user_pass_auto_rotation" {
  type        = bool
  description = "Whether to configure automatic rotation. Applies only to the `username_password` secret type."
  default     = true
}
variable "secret_user_pass_auto_rotation_unit" {
  type        = string
  description = "Specifies the unit of time for rotation of a username_password secret. Acceptable values are `day` or `month`."
  default     = "day" #tfsec:ignore:general-secrets-no-plaintext-exposure
}
variable "secret_user_pass_auto_rotation_interval" {
  type        = number
  description = "Specifies the rotation interval for the rotation unit."
  default     = 90
}

variable "service_endpoints" {
  type        = string
  description = "The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.service_endpoints)
    error_message = "The specified service_endpoints is not a valid selection!"
  }
}

##############################################################################
