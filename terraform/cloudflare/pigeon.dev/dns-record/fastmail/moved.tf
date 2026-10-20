# Keep until no state still holds the old addresses.
moved {
  from = cloudflare_dns_record.dkim_fm1
  to   = module.dns_record["dkim_fm1"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.dkim_fm2
  to   = module.dns_record["dkim_fm2"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.dkim_fm3
  to   = module.dns_record["dkim_fm3"].cloudflare_dns_record.this
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
  from = cloudflare_dns_record.spf
  to   = module.dns_record["spf"].cloudflare_dns_record.this
}
