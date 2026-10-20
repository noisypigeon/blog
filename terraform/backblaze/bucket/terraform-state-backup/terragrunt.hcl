include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = get_terragrunt_dir()
}

dependency "state_bucket" {
  config_path = "../../../cloudflare/bucket/terraform-state"
}

inputs = {
  state_bucket_name = dependency.state_bucket.outputs.name
}
