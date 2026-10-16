# Google Search Console site verification. One cloudflare/dns-record module
# call per record (LIB-0004). TTL 3600 and no comment, exactly as before.
locals {
  records = {
    site_verification = {
      name    = "@"
      type    = "TXT"
      content = "\"google-site-verification=vFu1wL_0hoMl6UpTkWZ3IiVSlfOvGuY_wtYfpWOrsfA\""
      ttl     = 3600
    }
  }
}

module "dns_record" {
  source   = "https://noisypigeon.garden/terraform/cloudflare/dns-record/v0.1.0"
  for_each = local.records

  zone_id  = local.cloudflare_zone_id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = try(each.value.proxied, null)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
}
