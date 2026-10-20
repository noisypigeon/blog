# Read by the generated /root.hcl. Bump root_hcl_version, then `mise run terraform-prepare`.
locals {
  root_hcl_version = "4.0.0"

  state_backend = "cloudflare"
  state_backup  = true

  providers = {
    cloudflare = {}
    backblaze  = { leaves = ["terraform/backblaze/"] }
  }
}
