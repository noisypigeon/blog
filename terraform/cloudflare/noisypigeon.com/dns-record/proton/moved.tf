# Keep until no state still holds the old addresses.
moved {
  from = cloudflare_dns_record.dkim_primary
  to   = module.dns_record["dkim_primary"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.dkim_secondary
  to   = module.dns_record["dkim_secondary"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.dkim_tertiary
  to   = module.dns_record["dkim_tertiary"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.dmarc
  to   = module.dns_record["dmarc"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.protonmail_verification
  to   = module.dns_record["protonmail_verification"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.pm_verification
  to   = module.dns_record["pm_verification"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.mx_primary
  to   = module.dns_record["mx_primary"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.mx_secondary
  to   = module.dns_record["mx_secondary"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.proton_spf
  to   = module.dns_record["proton_spf"].cloudflare_dns_record.this
}
