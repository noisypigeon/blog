# Keep until no state still holds the old addresses.
moved {
  from = cloudflare_dns_record.site_verification
  to   = module.dns_record["site_verification"].cloudflare_dns_record.this
}
