variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud APIkey that's associated with the account to provision resources in"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to use for naming of all resource created by this example"
  default     = "test-sm-secret-module"
}

variable "sm_service_plan" {
  type        = string
  description = "Description of service plan to be used to provision Secrets Manager if not passing a value for var.existing_sm_instance_guid"
  default     = "trial"
}

variable "region" {
  type        = string
  description = "Region to provision Secrets Manager in if not passing a value for var.existing_sm_instance_guid"
  default     = "au-syd"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to any created resources"
  default     = []
}

variable "existing_sm_instance_crn" {
  type        = string
  description = "An existing Secrets Manager instance CRN. If not provided an new instance will be provisioned."
  default     = null

  validation {
    condition = var.existing_sm_instance_crn != null ? var.existing_sm_instance_region != null : true
    error_message = "`existing_sm_instance_region` must also be set when value given for `existing_sm_instance_crn`."
  }
}

variable "existing_sm_instance_region" {
  type        = string
  description = "The region of the existing Secrets Manager instance. Only required if value is passed into var.existing_sm_instance_crn"
  default     = null
}
