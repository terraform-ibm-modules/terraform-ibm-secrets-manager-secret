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
  description = "Status of auto-rotation for username_password secret"
  value       = local.secret_user_pass_auto_rotation
}
output "user_pass_rotation_interval" {
  description = "Rotation frecuency for username_password secret"
  value       = local.username_password_secret_auto_rotation_frecuency
}
output "user_pass_next_rotation_date" {
  description = "Next rotation data for username_password secret"
  value       = local.username_password_secret_next_rotation_date
}
##############################################################################
