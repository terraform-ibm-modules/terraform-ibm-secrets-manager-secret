output "arbitrary_secret_id" {
  description = "ID of the created arbitrary_secret_id secret"
  value       = module.secrets_manager_arbitrary_secret.secret_id
}

output "arbitrary_secret_crn" {
  description = "CRN of the created arbitrary_secret_id secret"
  value       = module.secrets_manager_arbitrary_secret.secret_crn
}

output "arbitrary_secret_nonsensitive_payload" {
  value       = nonsensitive(data.ibm_sm_arbitrary_secret.arbitrary_secret.payload)
  description = "accessing arbitrary secret"
  sensitive   = false
}

output "arbitrary_secret_payload" {
  value       = data.ibm_sm_arbitrary_secret.arbitrary_secret.payload
  sensitive   = true
  description = "accessing arbitrary secret"
}

output "user_pass_secret_id" {
  description = "ID of the created username_password secret"
  value       = module.secrets_manager_user_pass_secret.secret_id
}

output "user_pass_secret_crn" {
  description = "CRN of the created username_password secret"
  value       = module.secrets_manager_user_pass_secret.secret_crn
}

output "user_pass_secret_nonsensitive_payload" {
  value       = nonsensitive(data.ibm_sm_username_password_secret.user_pass_secret.password)
  description = "accessing username_password secret"
  sensitive   = false
}

output "user_pass_secret_payload" {
  value       = data.ibm_sm_username_password_secret.user_pass_secret.password
  sensitive   = true
  description = "accessing arbitrary secret"
}

output "user_pass_no_rotate_secret_id" {
  description = "ID of the created username_password secret"
  value       = module.secrets_manager_user_pass_no_rotate_secret.secret_id
}

output "user_pass_no_rotate_secret_crn" {
  description = "CRN of the created username_password secret"
  value       = module.secrets_manager_user_pass_no_rotate_secret.secret_crn
}

output "user_pass_no_rotate_secret_nonsensitive_payload" {
  value       = nonsensitive(data.ibm_sm_username_password_secret.user_pass_no_rotate_secret.password)
  description = "accessing username_password secret"
  sensitive   = false
}

output "user_pass_no_rotate_secret_payload" {
  value       = data.ibm_sm_username_password_secret.user_pass_no_rotate_secret.password
  sensitive   = true
  description = "accessing arbitrary secret"
}

output "imported_cert_secret_id" {
  description = "ID of the created imported_cert secret"
  value       = module.secret_manager_imported_cert.secret_id
}

output "imported_cert_secret_crn" {
  description = "CRN of the created imported_cert secret"
  value       = module.secret_manager_imported_cert.secret_crn
}

output "service_credential_secret_id" {
  description = "ID of the created service_credential secret"
  value       = module.secret_manager_service_credential.secret_id
}

output "service_credential_secret_crn" {
  description = "CRN of the created service_credential secret"
  value       = module.secret_manager_service_credential.secret_crn
}

output "kv_secret_id" {
  description = "ID of the created kv_secret_id secret"
  value       = module.secrets_manager_key_value_secret.secret_id
}

output "kv_secret_crn" {
  description = "CRN of the created kv_secret_id secret"
  value       = module.secrets_manager_key_value_secret.secret_crn
}

output "kv_secret_nonsensitive_payload" {
  value       = nonsensitive(data.ibm_sm_kv_secret.kv_secret.data)
  description = "accessing key value secret"
  sensitive   = false
}

output "kv_secret_payload" {
  value       = data.ibm_sm_kv_secret.kv_secret.data
  sensitive   = true
  description = "accessing key value secret"
}

output "custom_credential_secret_id" {
  description = "ID of the created custom_credential secret"
  value       = module.secret_manager_custom_credential.secret_id
}

output "custom_credential_secret_crn" {
  description = "CRN of the created custom_credential secret"
  value       = module.secret_manager_custom_credential.secret_crn
}
