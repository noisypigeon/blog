# This spoke's instance values for pigeon-lib's root.hcl template (LIB-0003,
# COM-0003). /root.hcl is generated from that template at root_hcl_version by
# pigeon-lib's resolve-root-hcl.sh and committed -- never edit it by hand; CI
# fails if it drifts. The template reads the rest of these locals back out of
# this file.
locals {
  # pigeon-lib tag terragrunt/root-hcl/v<version>, or "main" for the fetched
  # clone's working tree. Bumping it is how this repo takes a template change.
  root_hcl_version = "2.2.1"

  # terraform/secrets.enc key naming this spoke's own state bucket: since
  # COM-0004 the R2 one, on the cloudflare backend (LIB-0007).
  state_bucket_secret = "NOISYPIGEON_COM_R2_TERRAFORM_STATE_BUCKET_NAME"
  state_backend       = "cloudflare"

  # Which providers this spoke's leaves get (LIB-0005). A provider absent from
  # the map is off; `leaves` scopes one to path prefixes ending in "/".
  # Scaleway has been off since COM-0005 retired this domain's last Scaleway
  # resources.
  providers = {
    cloudflare = {}
    backblaze  = { leaves = ["terraform/backblaze/"] }
  }
}
