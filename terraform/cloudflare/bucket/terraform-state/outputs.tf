output "name" {
  description = "R2 state bucket name -- hand-copy into terraform/secrets.enc's NOISYPIGEON_COM_R2_TERRAFORM_STATE_BUCKET_NAME"
  value       = module.bucket.name
}
