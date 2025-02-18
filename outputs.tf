##############################################################################
# Outputs
##############################################################################

output "secret_id" {
  description = "ID of the created Secret"
  value       = local.secret_id
}

output "secret_crn" {
  description = "CRN of the created Secret"
  value       = local.secret_crn
}

output "secret_group_id" {
  description = "Secret group ID of the created secret"
  value       = var.secret_group_id
}

output "secret_rotation" {
  description = "Status of auto-rotation for secret"
  value       = local.secret_auto_rotation
}

output "secret_rotation_interval" {
  description = "Rotation frecuency for secret (if applicable)"
  value       = local.secret_auto_rotation_frequency
}

output "secret_next_rotation_date" {
  description = "Next rotation date for secret (if applicable)"
  value       = local.secret_next_rotation_date
}

##############################################################################
