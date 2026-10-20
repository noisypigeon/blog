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
  source   = "https://noisypigeon.garden/terraform/cloudflare/dns-record/v1.0.0"
  for_each = local.records

  zone     = local.cloudflare_zone
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = try(each.value.proxied, null)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
}
