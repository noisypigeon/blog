# This spoke's instance values for pigeon-lib's root.hcl template (LIB-0003,
# COM-0003). /root.hcl is generated from that template at root_hcl_version by
# pigeon-lib's resolve-root-hcl.sh and committed -- never edit it by hand; CI
# fails if it drifts. The template reads the rest of these locals back out of
# this file.
locals {
  # pigeon-lib tag terragrunt/root-hcl/v<version>, or "main" for the fetched
  # clone's working tree. Bumping it is how this repo takes a template change.
  root_hcl_version = "4.0.0"

  # State lives in R2 (LIB-0007). Its bucket and keys are secrets.enc's
  # TERRAFORM_STATE_* (LIB-0010), so the Cloudflare provider must stay on.
  state_backend = "cloudflare"

  # R2 can't version objects, so state is copied to a versioned B2 bucket
  # (LIB-0007); its keys are terraform/secrets/terraform.enc's
  # TERRAFORM_STATE_BACKUP_* (LIB-0012).
  state_backup = true

  # Which providers this spoke's leaves get (LIB-0005). A provider absent from
  # the map is off; `leaves` scopes one to path prefixes ending in "/".
  # Scaleway has been off since COM-0005 retired this domain's last Scaleway
  # resources.
  providers = {
    cloudflare = {}
    backblaze  = { leaves = ["terraform/backblaze/"] }
  }
}
