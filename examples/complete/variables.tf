variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud APIkey that's associated with the account to provision resources in"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to use for naming of all resource created by this example"
  default     = "sm-secret-complete"
}

variable "sm_service_plan" {
  type        = string
  description = "Description of service plan to be used to provision Secrets Manager if not passing a value for var.existing_sm_instance_guid"
  default     = "trial"
}

variable "region" {
  type        = string
  description = "Region to provision Secrets Manager in if not passing a value for var.existing_sm_instance_guid"
  default     = "us-south" # Region is defaulted to us-south so as to restrict the code engine project to be created in the same region and have a hardcoded output image as `private.us`
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

variable "existing_sm_instance_guid" {
  type        = string
  description = "Existing Secrets Manager GUID. If not provided an new instance will be provisioned. If existing_sm_instance_guid needs to be used make sure the instance passed belongs to us-south region"
  default     = null

  validation {
    condition     = var.existing_sm_instance_guid != null ? var.existing_sm_instance_region != null : true
    error_message = "`existing_sm_instance_region` must also be set when value given for `existing_sm_instance_guid`."
  }
}

variable "existing_sm_instance_region" {
  type        = string
  description = "The region of the existing Secrets Manager instance. Only required if value is passed into var.existing_sm_instance_guid"
  default     = null
}
