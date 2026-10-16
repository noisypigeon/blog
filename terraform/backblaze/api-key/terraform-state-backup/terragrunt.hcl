include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = get_terragrunt_dir()
}

# The mock only lets this leaf plan before the bucket exists; apply always
# reads the real ID from the bucket leaf's state.
dependency "bucket" {
  config_path = "../../bucket/terraform-state-backup"

  mock_outputs = {
    bucket_id = "mock-bucket-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  bucket_id = dependency.bucket.outputs.bucket_id
}
