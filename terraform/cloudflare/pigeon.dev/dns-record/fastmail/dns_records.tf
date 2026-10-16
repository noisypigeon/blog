# Fastmail's DNS records for pigeon.dev: DKIM CNAMEs, MX, SPF. One
# cloudflare/dns-record module call per record (LIB-0004); every argument is
# exactly what the raw resources set -- proxied is left unset on the MX and
# TXT records, as it always was.
locals {
  records = {
    dkim_fm1 = {
      name    = "fm1._domainkey"
      type    = "CNAME"
      content = "fm1.pigeon.dev.dkim.fmhosted.com"
      ttl     = 1
      proxied = false
      comment = "fastmail primary dkim"
    }
    dkim_fm2 = {
      name    = "fm2._domainkey"
      type    = "CNAME"
      content = "fm2.pigeon.dev.dkim.fmhosted.com"
      ttl     = 1
      proxied = false
      comment = "fastmail secondary dkim"
    }
    dkim_fm3 = {
      name    = "fm3._domainkey"
      type    = "CNAME"
      content = "fm3.pigeon.dev.dkim.fmhosted.com"
      ttl     = 1
      proxied = false
      comment = "fastmail tertiary dkim"
    }
    mx_primary = {
      name     = "@"
      type     = "MX"
      content  = "in1-smtp.messagingengine.com"
      priority = 10
      ttl      = 1 # Auto
      comment  = "fastmail primary mx"
    }
    mx_secondary = {
      name     = "@"
      type     = "MX"
      content  = "in2-smtp.messagingengine.com"
      priority = 20
      ttl      = 1 # Auto
      comment  = "fastmail secondary mx"
    }
    spf = {
      name    = "@"
      type    = "TXT"
      content = "\"v=spf1 include:spf.messagingengine.com ?all\""
      ttl     = 1
      comment = "fastmail spf"
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
  comment  = each.value.comment
}
