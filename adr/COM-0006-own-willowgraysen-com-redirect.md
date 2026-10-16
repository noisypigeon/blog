# COM-0006: `noisypigeon.com` owns the `willowgraysen.com` redirect

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-16.
- **Status**: Accepted.
- **Amended 2026-10-16**: `pigeon.dev` followed by the same pattern
  (LIB-0009, DEV-0165). `fastmail` was copied from `noisypigeon/garden`'s R2
  bucket, and a placeholder pair and a ruleset redirect the domain to
  `https://noisypigeon.com`. It was the blog's home before this one, and it's
  an alias of the identity. An earlier version of this line said
  `https://noisypigeon.garden`, which was a planning error, corrected the same
  day.

## Context

LIB-0008 made `noisypigeon.com` the canonical identity: this repo is to own
every domain that redirects to it, each as a zone directory under
`terraform/cloudflare/<zone>/`. This repo adopted the layout for its own zone
first (#29). The first domain to move in is `willowgraysen.com`
(noisypigeon/noisypigeon#320).

Two leaves in `noisypigeon/willowgraysen` serve that redirect:

- **`cloudflare/dns-record/redirect`:** proxied placeholder records for the apex
  and `www`, so Cloudflare intercepts the traffic.
- **`cloudflare/ruleset/noisypigeon-com-redirect`:** the dynamic-redirect rule,
  a 301 to `https://noisypigeon.com`.

Both zones are on the same Cloudflare account, and this repo's
`CLOUDFLARE_TOKEN` already reaches `willowgraysen.com`. The two spokes keep
state on different backends. `noisypigeon/willowgraysen` uses Scaleway Object
Storage under `root.hcl` v2.0.0, and this repo uses R2 under v2.2.0 (COM-0004).

The repo was also renamed from `noisypigeon/willowgraysen.com` to
`noisypigeon/willowgraysen`. Nothing depends on the name: no workflow, guard,
dispatch or OIDC subject references it, the repo ID carries the secrets and the
ruleset, and no state key contains a repo name (LIB-0001 invariant 4).

## Decision

### 1. The two leaves move under the `willowgraysen.com` zone

| In `noisypigeon/willowgraysen` | Here |
| --- | --- |
| `terraform/cloudflare/dns-record/redirect` | `terraform/cloudflare/willowgraysen.com/dns-record/redirect` |
| `terraform/cloudflare/ruleset/noisypigeon-com-redirect` | `terraform/cloudflare/willowgraysen.com/ruleset/noisypigeon-com-redirect` |

They're copied rather than imported with their history: the history stays in
`noisypigeon/willowgraysen`, and the PR merges like any other, through the
apply. Each leaf's only change is `zone_id = local.cloudflare_zone_id`, which
`root.hcl` derives from the path (LIB-0008 §2). `spoke.hcl` and `root.hcl`
don't change.

### 2. The state is copied across buckets and backends

This is LIB-0008 §3 between two buckets, with one difference:
`rclone copyto` reads from the Scaleway bucket and writes to this repo's R2
bucket, byte for byte. Both remotes are configured only by environment
variables, from each repo's `secrets.enc`. Nothing is pushed, so serial and
lineage survive (COM-0004 §2). After this repo's plan shows `No changes.`,
`noisypigeon/willowgraysen` empties its old keys with `state rm`, then removes
the leaves and turns its Cloudflare provider off in its own PR.

### 3. One new secret

`terraform/secrets.enc` gains `ENV_CF_ZONE_ID_WILLOWGRAYSEN_COM`, the same
value `noisypigeon/willowgraysen` held. Without it, v2.2.0 fails the render of
both leaves.

## Consequences

- **This repo holds two zones.** A bad Terraform merge here can now break the
  `willowgraysen.com` redirect as well as this site.
- **The B2 backup covers the redirect,** since the new keys are in the R2
  bucket that `state-backup.yml` copies.
- **`noisypigeon/willowgraysen` no longer runs Cloudflare.** Its remaining
  leaves are Scaleway, Backblaze and Grafana.

## Out of scope

- **pigeon.dev's redirect** (noisypigeon/noisypigeon#321) and
  **noisypigeon.garden** (noisypigeon/noisypigeon#322) stay deferred, as LIB-0008
  records.
- **Changing what the redirect does.** The resources move unchanged. This is
  permanent for this record.

## Verification

1. **The rename.** After `gh repo rename`, `noisypigeon/willowgraysen` had the
   same repository ID, its `main` ruleset and all three Actions secrets.
2. **The copy.** Each new R2 object's SHA-256 matched its Scaleway source.
   `terragrunt state pull` at each new path on this record's branch matched a
   pull at the old path on `noisypigeon/willowgraysen`'s `main` in serial,
   lineage and resource count, for 3 instances across the two leaves.
3. **The secret.** The new `ENV_CF_ZONE_ID_WILLOWGRAYSEN_COM` hashed the same as
   the one in `noisypigeon/willowgraysen`.
4. **The plan.** Local `terragrunt plan` showed `No changes.` on both new
   leaves.
