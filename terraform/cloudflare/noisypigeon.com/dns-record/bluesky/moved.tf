# Keep until no state still holds the old addresses.
moved {
  from = cloudflare_dns_record.did
  to   = module.dns_record["did"].cloudflare_dns_record.this
}
