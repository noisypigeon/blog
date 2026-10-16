# COM-0004: move `noisypigeon.com`'s Terraform state to Cloudflare R2, backed up to B2

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-15.
- **Status**: Accepted.

## Context

Since COM-0003, this domain's Terraform state has lived in its own Scaleway
bucket, `NOISYPIGEON_COM_TERRAFORM_STATE_BUCKET_NAME`, which has object
versioning on (ADR-0132). LIB-0007 gives `root.hcl` v2.1.0 a second backend,
Cloudflare R2, chosen per spoke with `state_backend`. It also pairs an R2 state
bucket with a versioned Backblaze B2 copy, because R2 can't version objects.

This repo is the first to move. It has nine leaves, all small, and no other
open Terraform work. #19 created the three new ones:

- **`cloudflare/bucket/terraform-state`**: the R2 bucket,
  `com-mhp7ix-terraform-state`, EU jurisdiction (LIB-0006).
- **`backblaze/bucket/terraform-state-backup`**: the B2 bucket the state is
  copied into, `com-000mqm-terraform-state-backup`. It has no lifecycle rules,
  so B2 keeps every version.
- **`backblaze/api-key/terraform-state-backup`**: the copy job's key, with
  `listBuckets`, `listFiles` and `writeFiles` on that bucket only, never
  expiring.

Its first apply ran each new leaf twice, concurrently. A B2 bucket and key were
orphaned; they were deleted by hand, and pigeon-lib#41 (`workflows/v1.5.1`)
fixed the cause before the re-apply.

## Decision

### 1. State moves to R2

`spoke.hcl` takes `root_hcl_version = "2.1.0"` and sets:

- `state_backend = "cloudflare"`;
- `state_bucket_secret = "NOISYPIGEON_COM_R2_TERRAFORM_STATE_BUCKET_NAME"`.

The R2 S3 keys, `CLOUDFLARE_R2_ACCESS_KEY_ID` and
`CLOUDFLARE_R2_SECRET_ACCESS_KEY`, are an R2 API token made by hand, with
*Object Read & Write* scoped to the state bucket. Cloudflare has no Terraform
resource for them.

### 2. Objects are copied, not pushed

Each of the nine leaves' `terraform/<leaf>/terraform.tfstate` was copied from
the Scaleway bucket to the same key in R2 with `rclone copyto`, byte for byte.

`terraform state push` was tried first, on one leaf. Into a freshly initialized
R2 backend, it kept the new remote's lineage rather than the source's. A
straight object copy keeps serial and lineage, which is what makes the move
checkable. That leaf was then overwritten by the copy.

The bucket-scoped R2 token can't create buckets, so rclone runs with
`--s3-no-check-bucket`.

The older keys still in the Scaleway bucket, left by the LIB-0004 renames and
emptied then, were not copied.

### 3. The Scaleway state stays as a frozen rollback copy

Nothing reads the Scaleway bucket after this change. Its objects, and their
version history, are left exactly as they were at the move.
`NOISYPIGEON_COM_TERRAFORM_STATE_BUCKET_NAME` stays in `secrets.enc`. Reverting
this record's PR switches back to Scaleway, with any state written since then
copied back first. The `scaleway/object-bucket/terraform-state` leaf still
manages that bucket; its own state is now in R2.

### 4. State is copied to B2 after every apply and daily

- **After every apply:** `terragrunt-apply.yml` gains a `backup` job that
  calls pigeon-lib's `state-backup.yml` (`workflows/v1.5.1`). It runs even after
  a failed apply, which may still have written state.
- **Daily, and on demand:** a new `state-backup.yml` caller runs the same copy
  on a schedule and on `workflow_dispatch`. That picks up local applies.

The job reads `TERRAFORM_STATE_BACKUP_B2_BUCKET_NAME`,
`TERRAFORM_STATE_BACKUP_B2_KEY_ID` and `TERRAFORM_STATE_BACKUP_B2_KEY` from
`secrets.enc`. They're hand-copied from the backup leaves' outputs.

## Consequences

- **This domain's state costs nothing to keep or read.** It fits well within
  R2's free tier and R2 has no egress fees. B2 bills only for the versions it keeps.
- **A bad state write is recoverable from B2,** from the version the last copy
  took. After a CI apply that's the state just before it; after a local apply,
  at most a day old. A restore needs an admin B2 key.
- **The R2 bucket leaf's state lives in the bucket it manages,** as the
  Scaleway bucket's did. Destroying it would destroy every leaf's state.
- **`secrets.enc` grows by six keys:** two R2 keys, the R2 bucket name and
  three for the backup.

## Out of scope

- **Retiring the Scaleway state bucket** and its leaf, and deciding what
  happens to its versioned history. Deferred until R2 has run cleanly for a
  while.
- **State locking.** LIB-0007 defers it for every spoke.
- **`state/iam`'s deploy key.** It still authenticates the Scaleway leaves and
  provider, unchanged (COM-0003, LIB-0001 §8). Permanent for this record.

## Verification

1. **The copy.** For all nine leaves, `terragrunt state pull` from R2 on this
   record's branch matched the pull from Scaleway on a worktree of `main` in
   serial, lineage and resource count.
2. **The plan.** `mise run plan` on this branch, against R2, showed
   `No changes.` on 9/9 leaves.
