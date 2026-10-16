# Placeholder records so Cloudflare intercepts willowgraysen.com and www for
# the noisypigeon.com redirect below. One cloudflare/dns-record module call per
# record (LIB-0004); every argument is exactly what the raw resources set.
locals {
  records = {
    placeholder_apex = {
      name    = "@"
      type    = "A"
      content = "192.0.2.1"
      proxied = true
      ttl     = 1
      comment = "placeholder so Cloudflare intercepts apex traffic for the noisypigeon.com redirect"
    }
    placeholder_www = {
      name    = "www"
      type    = "CNAME"
      content = "willowgraysen.com"
      proxied = true
      ttl     = 1
      comment = "placeholder so Cloudflare intercepts www traffic for the noisypigeon.com redirect"
    }
  }
}

module "dns_record" {
  source   = "https://pigeon.dev/modules/cloudflare/dns-record/v0.1.0"
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
