# No read or delete, so a backup job can never erase history. Never expires: an expired key silently stops backups.
module "key" {
  source                    = "https://noisypigeon.garden/terraform/backblaze/api-key/v0.1.1"
  key_name                  = "blog-terraform-state-backup"
  bucket_ids                = [var.bucket_id]
  capabilities              = ["listBuckets", "listFiles", "writeFiles"]
  valid_duration_in_seconds = null
}
