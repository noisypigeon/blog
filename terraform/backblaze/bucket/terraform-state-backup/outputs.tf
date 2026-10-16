output "bucket_id" {
  description = "Backup bucket ID -- read by the terraform-state-backup api-key leaf through a Terragrunt dependency"
  value       = module.bucket.bucket_id
}

output "bucket_name" {
  description = "Backup bucket name -- hand-copy into terraform/secrets.enc's TERRAFORM_STATE_BACKUP_B2_BUCKET_NAME"
  value       = module.bucket.bucket_name
}
