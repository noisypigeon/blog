# pigeon.dev was the blog's home before noisypigeon.com and remains an alias of
# the identity, so every path goes to the noisypigeon.com homepage, the same as
# willowgraysen.com's redirect.
module "ruleset" {
  source = "https://noisypigeon.garden/terraform/cloudflare/ruleset/v0.1.0"

  zone_id = local.cloudflare_zone_id
  name    = "pigeon.dev to noisypigeon.com redirect"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    expression  = "(http.host eq \"pigeon.dev\") or (http.host eq \"www.pigeon.dev\")"
    description = "redirect pigeon.dev and www to the noisypigeon.com homepage"
    action      = "redirect"
    action_parameters = {
      from_value = {
        status_code = 301
        target_url = {
          value = "https://noisypigeon.com"
        }
        preserve_query_string = false
      }
    }
  }]
}
