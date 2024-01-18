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

output "user_pass_rotation" {
  description = "Status of auto-rotation for secret"
  value       = local.secret_auto_rotation
}

output "user_pass_rotation_interval" {
  description = "Rotation frecuency for secret (if applicable)"
  value       = local.secret_auto_rotation_frequency
}

output "user_pass_next_rotation_date" {
  description = "Next rotation data for secret (if applicable)"
  value       = local.secret_next_rotation_date
}

##############################################################################
