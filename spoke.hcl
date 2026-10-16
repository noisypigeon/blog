# This spoke's instance values for pigeon-lib's root.hcl template (LIB-0003,
# COM-0003). /root.hcl is generated from that template at root_hcl_version by
# pigeon-lib's resolve-root-hcl.sh and committed -- never edit it by hand; CI
# fails if it drifts. The template reads the rest of these locals back out of
# this file.
locals {
  # pigeon-lib tag terragrunt/root-hcl/v<version>, or "main" for the fetched
  # clone's working tree. Bumping it is how this repo takes a template change.
  root_hcl_version = "2.0.0"

  # terraform/secrets.enc key naming this spoke's own state bucket (ADR-0132).
  state_bucket_secret = "NOISYPIGEON_COM_TERRAFORM_STATE_BUCKET_NAME"

  # Which providers this spoke's leaves get (LIB-0005). A provider absent from
  # the map is off; `leaves` scopes one to path prefixes ending in "/".
  providers = {
    cloudflare = {}
    scaleway   = {}
    backblaze  = { leaves = ["terraform/backblaze/"] }
  }
}
