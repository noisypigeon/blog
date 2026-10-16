# The raw cloudflare_dns_record resources this leaf used to declare, moved
# under the cloudflare/dns-record module without touching the records
# themselves (LIB-0004 §3). Keep these until every state that might still hold
# the old addresses has been applied past them.
moved {
  from = cloudflare_dns_record.site_verification
  to   = module.dns_record["site_verification"].cloudflare_dns_record.this
}
