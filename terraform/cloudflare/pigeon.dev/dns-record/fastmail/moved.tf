# The raw cloudflare_dns_record resources this leaf used to declare, moved
# under the cloudflare/dns-record module without touching the records
# themselves (LIB-0004 §3). Keep these until every state that might still hold
# the old addresses has been applied past them.
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
