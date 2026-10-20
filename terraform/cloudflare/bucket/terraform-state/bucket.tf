# This leaf's own state lives in the bucket it manages: never destroy it.
module "bucket" {
  source      = "https://noisypigeon.garden/terraform/cloudflare/bucket/v1.0.0"
  account_id  = local.cloudflare_account_id
  name_prefix = local.name_prefix
  name_suffix = local.name_suffix
}
