# pigeon.dev redirects to the noisypigeon.com homepage. Its placeholder records and the
# 301 ruleset are one cloudflare/apex-redirect module (LIB-0011).
module "apex_redirect" {
  source = "https://noisypigeon.garden/terraform/cloudflare/apex-redirect/v0.1.0"

  zone       = local.cloudflare_zone
  target_url = "https://noisypigeon.com"
}
