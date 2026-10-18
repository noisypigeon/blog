# The key state-backup.yml copies state into B2 with (LIB-0007 §4): it can find
# the bucket, list it and add file versions, and nothing else -- no read, no
# delete -- so the job can never erase backup history. It never expires: an
# expired key would silently stop the backups.
module "key" {
  source                    = "https://noisypigeon.garden/terraform/backblaze/api-key/v0.1.1"
  key_name                  = "blog-terraform-state-backup"
  bucket_ids                = [var.bucket_id]
  capabilities              = ["listBuckets", "listFiles", "writeFiles"]
  valid_duration_in_seconds = null
}
