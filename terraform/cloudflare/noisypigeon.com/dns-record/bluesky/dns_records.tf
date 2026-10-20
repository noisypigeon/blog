locals {
  records = {
    did = {
      name    = "_atproto"
      type    = "TXT"
      content = "did=did:plc:kkh3qo4rjs4b6aayzj4fcpkg"
      ttl     = 1
      comment = "bluesky domain handle"
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
