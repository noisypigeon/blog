# The offsite, versioned copy of the R2 state bucket (LIB-0007 §4). B2 keeps
# every version of a file unless a lifecycle rule says otherwise, and none is
# set: that history is the point of this bucket.
module "bucket" {
  source      = "https://noisypigeon.garden/terraform/backblaze/bucket/v0.1.1"
  name_prefix = local.name_prefix
  name_suffix = local.name_suffix
  description = local.description
}
