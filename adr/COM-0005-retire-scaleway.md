# COM-0005: retire `noisypigeon.com`'s Scaleway resources and turn the provider off

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-16.
- **Status**: Accepted.

## Context

COM-0004 moved this domain's Terraform state to Cloudflare R2, backed up to
Backblaze B2. That left the domain with three Scaleway pieces:

- **`scaleway/object-bucket/terraform-state`:** the old state bucket
  (`noisypigeon-com-tunkbk-terraform-state`), kept as a frozen rollback copy
  that nothing read.
- **`scaleway/project/com`:** the `noisypigeon-com` project. A preflight listing
  of the project's Object Storage in fr-par, nl-ams and pl-waw found the state
  bucket and nothing else.
- **The deploy key:** `noisypigeon-com-terraform-deploy`, minted by
  `noisypigeon.com/terraform/state/iam` in `noisypigeon/noisypigeon`
  (COM-0003, LIB-0001 §8). It's the key this spoke's Scaleway provider and old
  backend authenticated with.

Nothing else in this domain uses Scaleway. Every other leaf is Cloudflare or
Backblaze. COM-0004 deferred retiring the bucket until R2 had run cleanly
(noisypigeon/noisypigeon#317). It has, through three applies, each followed by
a successful B2 backup.

## Decision

### 1. All three go

1. **The bucket.** #25 set `force_destroy = true` and applied it on its own,
   because a destroy only empties a versioned bucket if that setting is already
   in state. #26 then removed the leaf, and CI destroyed the bucket with every
   object version in it.
2. **The project.** #27 removed `scaleway/project/com` and destroyed the
   now-empty project. It was a separate PR because a removed leaf can't declare
   a dependency, and the project can't go while it still holds a bucket.
3. **The deploy key.** `noisypigeon/noisypigeon` destroys `state/iam` in its own
   PR, last, because the destroys above authenticated with it.

### 2. The bucket's version history is let go

The old bucket's versions were the state's history before COM-0004. They were
destroyed with the bucket, not exported. The current state lives in R2, and
every write since COM-0004 is versioned in B2.

### 3. Scaleway is off through LIB-0005's map

`spoke.hcl` drops `scaleway` from `providers`. No template change is needed:
`root.hcl` v2.1.0 already turns off any provider absent from the map. Every
leaf's Scaleway generated files become a one-line comment, and no leaf requires
`scaleway/scaleway`.

With `state_backend = "cloudflare"`, nothing else reads Scaleway keys. The
template's Scaleway backend config is built but never selected, and every
`SCALEWAY_*` lookup falls back to empty.

### 4. The Scaleway secrets are removed

`terraform/secrets.enc` loses `SCALEWAY_ACCESS_KEY`, `SCALEWAY_SECRET_KEY`,
`SCALEWAY_ORGANIZATION_ID`, `SCALEWAY_PROJECT_ID` and
`NOISYPIGEON_COM_TERRAFORM_STATE_BUCKET_NAME`, which named the old bucket.

## Consequences

- **COM-0004's rollback path is gone.** Reverting its cutover now has no Scaleway
  copy to fall back to. Recovering state means a restore from B2, following
  pigeon-lib's `docs/runbooks/restore-terraform-state-from-b2.md`.
- **The domain runs on two providers,** Cloudflare everywhere and Backblaze for
  `terraform/backblaze/`, with seven leaves.
- **This domain's `state/iam` question is settled.** It resolves
  noisypigeon/noisypigeon#308 for `noisypigeon.com` by retirement: there's no
  deploy key left to bootstrap. `willowgraysen.com` still has to decide.
- **The emptied state objects** of the two removed leaves stay in R2 and B2,
  harmless, like the keys left by the LIB-0004 renames.

## Out of scope

- **Re-adding Scaleway.** It would mean a new key, the provider back in the
  map, and new leaves. That's a later decision if one is ever needed, not a
  deferral.
- **The other spokes' Scaleway use.** `pigeon.dev` and `willowgraysen.com`
  keep their projects. Permanent for this record.

## Verification

1. **The bucket.** #26's apply destroyed two resources, the bucket and its
   suffix. Afterwards, a listing of fr-par Object Storage with the deploy key
   returned no buckets.
2. **The project.** #27's apply destroyed one resource. Afterwards, the
   organization's projects were `willowgraysen` and `pigeon-dev`.
3. **Scaleway off.** With `scaleway` dropped from `providers`, `mise run plan`
   showed `No changes.` on all seven remaining leaves.
