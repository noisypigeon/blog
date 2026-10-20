# No lifecycle rule: the version history is the point of this bucket.
module "bucket" {
  source      = "https://noisypigeon.garden/terraform/backblaze/bucket/v0.2.0"
  exact_name  = local.exact_name
  description = local.description
}
