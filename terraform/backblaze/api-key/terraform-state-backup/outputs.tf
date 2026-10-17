output "application_key_id" {
  description = "Backup key ID -- hand-copy into terraform/secrets/terraform.enc's TERRAFORM_STATE_BACKUP_ACCESS_KEY_ID"
  value       = module.key.application_key_id
}

output "application_key" {
  description = "Backup key -- hand-copy into terraform/secrets/terraform.enc's TERRAFORM_STATE_BACKUP_ACCESS_KEY; never print it"
  value       = module.key.application_key
  sensitive   = true
}
