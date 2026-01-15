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
  description = "Type of secret to create, must be one of: arbitrary, username_password, imported_cert, service_credentials, custom_credentials"

  validation {
    condition     = contains(["arbitrary", "username_password", "imported_cert", "key_value", "service_credentials", "custom_credentials"], var.secret_type) #checkov:skip=CKV_SECRET_6
    error_message = "Only supported secrets types are arbitrary, username_password, key_value , imported_cert, service_credentials or custom_credentials"
  }

  validation {
    condition     = (var.secret_type == "username_password" || var.secret_type == "arbitrary") ? var.secret_payload_password != "" : true
    error_message = "When creating a username_password or arbitrary secret, a value for `secret_payload_password` is required."
  }

  validation {
    condition     = var.secret_type == "key_value" ? var.secret_kv_data != null : true
    error_message = "When creating a key_value secret, a value for `secret_kv_data` is required."
  }

  validation {
    condition     = var.secret_type == "imported_cert" ? var.imported_cert_certificate != null : true
    error_message = "When creating an imported_cert secret, value for `imported_cert_certificate` cannot be null."
  }

  validation {
    condition     = var.secret_type == "service_credentials" ? var.service_credentials_source_service_crn != null && var.service_credentials_source_service_role_crn != null : true
    error_message = "When creating a service_credentials secret, values for `service_credentials_source_service_crn` and `service_credentials_source_service_role_crn` are required."
  }

  validation {
    condition     = var.secret_type != "custom_credentials" || var.custom_credentials_configurations != null
    error_message = "The 'custom_credentials_configurations' variable must be set when 'secret_type' is 'custom_credentials'."
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
  description = "Labels that can be used to search for secrets within the instance. Up to 30 labels can be created. Labels can be between 2 and 64 characters."
  default     = []

  validation {
    condition     = length(var.secret_labels) <= 30
    error_message = "Up to 30 labels can be created."
  }

  validation {
    condition = alltrue([
      for label in var.secret_labels : length(label) <= 64 && length(label) >= 2
    ])
    error_message = "Labels must be between 2 and 64 characters."
  }
}

variable "secret_payload_password" {
  type        = string
  description = "The payload (for arbitrary secrets) or password (for username and password credentials) of the secret."
  sensitive   = true
  default     = "" #tfsec:ignore:general-secrets-no-plaintext-exposure
}

variable "secret_kv_data" {
  type        = map(string)
  description = "key-value secret data"
  sensitive   = true
  default     = null
}

variable "secret_auto_rotation" {
  type        = bool
  description = "Whether to configure automatic rotation. Applies only to the `username_password` and `service_credentials` secret types."
  default     = true
}

variable "secret_auto_rotation_unit" {
  type        = string
  description = "Specifies the unit of time for rotation of a username_password secret. Acceptable values are `day` or `month`."
  default     = "day" #tfsec:ignore:general-secrets-no-plaintext-exposure

  validation {
    condition     = contains(["day", "month"], var.secret_auto_rotation_unit)
    error_message = "Value for `secret_auto_rotation_unit' must be either `day` or `month`."
  }
}

variable "secret_auto_rotation_interval" {
  type        = number
  description = "Specifies the rotation interval for the rotation unit."
  default     = 89

  validation {
    condition     = var.secret_auto_rotation_interval > 0
    error_message = "Value for `secret_auto_rotation_interval` must be higher than 0."
  }
}

variable "service_credentials_ttl" {
  type        = number
  description = "The time-to-live (TTL) to assign to generated service credentials (in seconds)."
  default     = "7776000" # 90 days

  validation {
    condition     = (var.service_credentials_ttl >= 86400) && (var.service_credentials_ttl <= 7776000)
    error_message = "TTL must be between 86400 (1 day) and 7776000 (90 days)."
  }
}

variable "service_credentials_source_service_crn" {
  type        = string
  description = "The CRN of the source service instance to create the service credential."
  default     = null
}

variable "service_credentials_source_service_role_crn" {
  type        = string
  description = "The CRN for the role to give the service credential in the source service. See https://cloud.ibm.com/iam/roles"
  default     = null
}

variable "service_credentials_parameters" {
  type        = map(string)
  description = "List of all custom parameters for service credential."
  default     = null

  validation {
    condition     = var.service_credentials_parameters != null ? !(var.service_credentials_source_service_hmac == true || var.service_credentials_existing_serviceid_crn != null) : true
    error_message = "You are passing in a custom set of service credential parameters while also using variables that auto-set parameters."
  }
}

variable "service_credentials_source_service_hmac" {
  type        = bool
  description = "The optional boolean parameter 'HMAC' for creating specific kind of credentials. For more information see https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_service_credentials_secret#parameters"
  default     = false
}

variable "service_credentials_existing_serviceid_crn" {
  type        = string
  description = "The optional parameter 'serviceid_crn' for creating service credentials. If not passed in, a new Service ID will be created. For more information see https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_service_credentials_secret#parameters"
  default     = null
}

variable "endpoint_type" {
  type        = string
  description = "The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.endpoint_type)
    error_message = "The specified endpoint_type is not a valid selection!"
  }
}

variable "custom_metadata" {
  type        = map(string)
  description = "Optional metadata to be added to the secret."
  default     = null
}

variable "custom_credentials_configurations" {
  type        = string
  description = "The name of the custom credentials secret configuration."
  default     = null
}

variable "custom_credentials_parameters" {
  type        = bool
  description = "Whether to create parameters for custom credentials secret or not"
  default     = false
}

variable "job_parameters" {
  description = "The parameters that are passed to the Code Engine job."
  type = object({
    integer_values = optional(map(number))
    string_values  = optional(map(string))
    boolean_values = optional(map(bool))
  })
  default = {}
}
##############################################################################
