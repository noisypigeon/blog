# Being retired (COM-0005, noisypigeon/noisypigeon#317): state moved to R2 in
# COM-0004. force_destroy has to be in state before the leaf is removed, so
# the destroy can empty this versioned bucket -- every version goes with it.
module "bucket" {
  source            = "https://pigeon.dev/modules/scaleway/object-bucket/v4.1.1"
  name_prefix       = local.name_prefix
  name_suffix       = local.name_suffix
  project_id        = local.scaleway_project_id
  enable_versioning = true
  storage_class     = "standard"
  force_destroy     = true
}
