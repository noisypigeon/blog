# Keep until no state still holds the old addresses.
moved {
  from = cloudflare_dns_record.placeholder_www
  to   = cloudflare_dns_record.www_cname
}

moved {
  from = cloudflare_dns_record.root_cname
  to   = module.dns_record["root_cname"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.www_cname
  to   = module.dns_record["www_cname"].cloudflare_dns_record.this
}
