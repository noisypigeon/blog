output "name" {
  description = "R2 state bucket name -- hand-copy into terraform/secrets.enc's TERRAFORM_STATE_BUCKET_NAME"
  value       = module.bucket.name
}
