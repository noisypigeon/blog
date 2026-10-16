# DNS records to point noisypigeon.com (apex + www) at GitHub Pages
# (noisypigeon.github.io) -- ADR-0158 cuts the site back over from the
# Scaleway bucket this leaf used to front. Both DNS-only (proxied = false),
# restoring the pre-ADR-0132 shape exactly: GitHub Pages issues its own
# Let's Encrypt certificate for the custom domain, which it cannot do while
# Cloudflare is proxying (and terminating TLS for) the apex, and it
# redirects www -> apex natively, so no separate redirect rule is needed
# here (mirrors pigeon.dev/terraform/wiki/dns/cname.tf, ADR-0156).
#
# One cloudflare/dns-record module call per record (LIB-0004).
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
