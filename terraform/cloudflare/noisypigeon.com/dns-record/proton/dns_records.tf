# Proton Mail's DNS records for noisypigeon.com: DKIM, DMARC, domain
# verification, MX, SPF. One cloudflare/dns-record module call per record
# (LIB-0004); every argument is exactly what the raw resources set --
# including dkim_tertiary's comment.
locals {
  records = {
    dkim_primary = {
      name    = "dkim._domainkey"
      type    = "CNAME"
      content = "dkim._domainkey.alias.proton.me"
      proxied = false
      ttl     = 1
      comment = "proton primary dkim"
    }
    dkim_secondary = {
      name    = "dkim02._domainkey"
      type    = "CNAME"
      content = "dkim02._domainkey.alias.proton.me"
      proxied = false
      ttl     = 1
      comment = "proton secondary dkim"
    }
    dkim_tertiary = {
      name    = "dkim03._domainkey"
      type    = "CNAME"
      content = "dkim03._domainkey.alias.proton.me"
      proxied = false
      ttl     = 1
      comment = "fastmail tertiary dkim"
    }
    dmarc = {
      name    = "_dmarc"
      type    = "TXT"
      content = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
      ttl     = 1
      comment = "proton spf verification"
    }
    protonmail_verification = {
      name    = "@"
      type    = "TXT"
      content = "protonmail-verification=e9457a054010bbbb12cc4abfce39d67198e9abd1"
      ttl     = 1
      comment = "protonmail verification"
    }
    pm_verification = {
      name    = "@"
      type    = "TXT"
      content = "pm-verification=yulfrkphygclvbkaipymgmyhstrxuj"
      ttl     = 1
      comment = "pm verification"
    }
    mx_primary = {
      name     = "@"
      type     = "MX"
      content  = "mx1.alias.proton.me"
      priority = 10
      ttl      = 1
      comment  = "protonmail primary mx"
    }
    mx_secondary = {
      name     = "@"
      type     = "MX"
      content  = "mx2.alias.proton.me"
      priority = 20
      ttl      = 1
      comment  = "protonmail secondary mx"
    }
    proton_spf = {
      name    = "@"
      type    = "TXT"
      content = "v=spf1 include:alias.proton.me ~all"
      ttl     = 1
      comment = "proton spf verification"
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
