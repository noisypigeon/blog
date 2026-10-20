# DNS-only: GitHub Pages can't issue its certificate behind the proxy, and redirects www itself.
locals {
  records = {
    root_cname = {
      name    = "@"
      type    = "CNAME"
      content = "noisypigeon.github.io"
      proxied = false
      ttl     = 1
      comment = "github pages root cname (apex, cloudflare-flattened)"
    }
    www_cname = {
      name    = "www"
      type    = "CNAME"
      content = "noisypigeon.github.io"
      proxied = false
      ttl     = 1
      comment = "github pages www cname"
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
