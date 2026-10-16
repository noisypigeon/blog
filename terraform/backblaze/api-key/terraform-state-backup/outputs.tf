output "application_key_id" {
  description = "Backup key ID -- hand-copy into terraform/secrets.enc's TERRAFORM_STATE_BACKUP_B2_KEY_ID"
  value       = module.key.application_key_id
}

output "application_key" {
  description = "Backup key -- hand-copy into terraform/secrets.enc's TERRAFORM_STATE_BACKUP_B2_KEY; never print it"
  value       = module.key.application_key
  sensitive   = true
}
