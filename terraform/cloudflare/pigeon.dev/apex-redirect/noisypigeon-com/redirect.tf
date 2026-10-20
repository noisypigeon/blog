module "apex_redirect" {
  source = "https://noisypigeon.garden/terraform/cloudflare/apex-redirect/v0.1.0"

  zone       = local.cloudflare_zone
  target_url = "https://noisypigeon.com"
}
