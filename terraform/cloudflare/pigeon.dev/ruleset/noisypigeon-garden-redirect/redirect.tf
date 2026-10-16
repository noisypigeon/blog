# pigeon.dev's site moved to noisypigeon.garden (DEV-0165). Every path goes to
# the garden's homepage: the old module short URLs are retired, not preserved
# (LIB-0009 §2).
module "ruleset" {
  source = "https://noisypigeon.garden/terraform/cloudflare/ruleset/v0.1.0"

  zone_id = local.cloudflare_zone_id
  name    = "pigeon.dev to noisypigeon.garden redirect"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    expression  = "(http.host eq \"pigeon.dev\") or (http.host eq \"www.pigeon.dev\")"
    description = "redirect pigeon.dev and www to the noisypigeon.garden homepage"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          value = "https://noisypigeon.garden"
        }
        preserve_query_string = false
      }
    }
  }]
}
