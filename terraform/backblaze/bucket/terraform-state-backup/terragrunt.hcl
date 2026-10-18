include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = get_terragrunt_dir()
}

# The backup is named after the R2 state bucket it copies (LIB-0016 §2). No
# mock: the state bucket always exists before this leaf can plan.
dependency "state_bucket" {
  config_path = "../../../cloudflare/bucket/terraform-state"
}

inputs = {
  state_bucket_name = dependency.state_bucket.outputs.name
}
