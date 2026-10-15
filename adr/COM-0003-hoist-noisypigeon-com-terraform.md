# COM-0003: hoist `noisypigeon.com`'s Terraform into this repo, leaving `state/iam` behind

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-15.
- **Status**: Accepted.

## Context

LIB-0001 §7 step 4 gives this repo "the same two steps" as `pigeon.dev`. The
content half is COM-0001 and COM-0002. This is the Terraform half. It follows
the path DEV-0163 has just walked for `pigeon.dev`, and needs nothing new from
the hub: template `terragrunt/root-hcl/v1.0.1` and `workflows/v1.3.1` already
serve it (LIB-0003).

Checked against `noisypigeon/noisypigeon@87a5089`, this domain has seven leaves
there, under `noisypigeon.com/terraform/`.

- **Six include `noisypigeon.com/root.hcl`** through `find_in_parent_folders`.
  They read `noisypigeon.com/secrets.enc`, and keep state in this domain's own
  bucket (ADR-0132) under `${path_relative_to_include()}/terraform.tfstate`:
  - `blog/dns`: the GitHub Pages CNAMEs that put this site online (ADR-0158);
  - `proton/dns`: this domain's mail records (MX, SPF, DKIM, DMARC and domain
    verification);
  - `bluesky/dns` and `google-search/dns`: handle and site-verification TXT
    records;
  - `project` and `state/bucket`.
- **`state/iam` includes `${get_repo_root()}/root.hcl`,** the monorepo's shared
  root. It mints `noisypigeon-com-terraform-deploy`, the key the other six
  authenticate with. That is LIB-0001 §8's problem, tracked as
  noisypigeon/noisypigeon#308.

## Decision

### 1. `state/iam` stays in `noisypigeon` (LIB-0001 §8, option 1)

This is the same choice and the same reasoning as DEV-0163 §1. A bootstrap root
here would copy the organisation-level shared deployer credentials into this
repo. Accepting the self-reference would reverse DEV-0130/0132/0133 and move
state between buckets. Leaving the leaf behind moves neither.

Rotating the deploy key is a PR in `noisypigeon` that applies
`noisypigeon.com/terraform/state/iam`, then a `mise run secrets-edit` here. With
this choice, #308 is left with `willowgraysen.com` alone.

### 2. The other six move with their history, and their state does not move

The leaves were imported with one `git filter-repo` pass over a fresh clone of
`noisypigeon`.

- **Kept:** this domain's own paths, `noisypigeon.com/` and `workloads/noisypigeon.com/`.
- **Renamed:** `…/terraform/` → `terraform/` and `…/secrets.enc` →
  `terraform/secrets.enc`.
- **Dropped:** `terraform/state/iam/`. Tags were dropped before filtering.

The result was 21 files and 7 commits, the oldest being noisypigeon#208. It was
merged with `--allow-unrelated-histories`. The imported tree is byte-identical
to the source, `secrets.enc` included.

**State does not move.** LIB-0001 invariant 4's arithmetic, written out:

| Leaf | Key in `noisypigeon` (under `noisypigeon.com/root.hcl`) | Key here (under `/root.hcl`) |
| --- | --- | --- |
| `blog/dns` | `terraform/blog/dns/terraform.tfstate` | `terraform/blog/dns/terraform.tfstate` |
| `bluesky/dns` | `terraform/bluesky/dns/terraform.tfstate` | `terraform/bluesky/dns/terraform.tfstate` |
| `google-search/dns` | `terraform/google-search/dns/terraform.tfstate` | `terraform/google-search/dns/terraform.tfstate` |
| `project` | `terraform/project/terraform.tfstate` | `terraform/project/terraform.tfstate` |
| `proton/dns` | `terraform/proton/dns/terraform.tfstate` | `terraform/proton/dns/terraform.tfstate` |
| `state/bucket` | `terraform/state/bucket/terraform.tfstate` | `terraform/state/bucket/terraform.tfstate` |

The bucket is the same too: `NOISYPIGEON_COM_TERRAFORM_STATE_BUCKET_NAME`, read
from the same encrypted file.

### 3. `root.hcl` comes from pigeon-lib's template, committed

`root.hcl` is pigeon-lib's `terragrunt/root-hcl` template at `1.0.1`, the version
`spoke.hcl` pins. `spoke.hcl` also names this spoke's one varying value,
`state_bucket_secret`.

It is committed rather than ignored, because Terragrunt's git filter plans inside
worktrees (LIB-0003's amendment). CI runs `resolve-root-hcl.sh --check` against
it, so drift fails the plan.

Before any PR, each of the six leaves was rendered with
`terragrunt render --format=json` under `noisypigeon.com/root.hcl` and under the
template. After normalizing the two trees' paths, the renders differ in zero
keys, and the state keys are literally equal.

### 4. CI, tooling and the merge gate

- **`terragrunt-plan.yml` and `terragrunt-apply.yml`** are copied from
  `pigeon.dev`'s (DEV-0163 §4): the same `leaf_pattern`,
  `secrets_files: terraform/secrets.enc`, and a `prepare_cmd` that fetches the
  library and runs `--check`.
- **All six workflow references and `.lib-version`** move from `v1.2.0` to
  `v1.3.1`. Between those tags, nothing the Pages, blog-changelog or
  root-changelog callers use changed.
- **Tooling:** `.sops.yaml` has one rule, `^terraform/secrets\.enc$`. `.mise.toml`
  gains Terraform, Terragrunt and sops plus the `plan`, `apply`,
  `terraform-prepare`, `fmt-terraform` and `secrets-edit` tasks; the blog tasks
  and the postinstall hook are unchanged. `.gitignore` gains the Terraform
  working-state patterns, but not `root.hcl`.
- **`root-changelog.yml`** tags `terraform/`, `root.hcl`, `spoke.hcl` and
  `.sops.yaml` changes as `terraform`, after `web/` → `blog`.
- **`main` gets `noisypigeon`'s ruleset (ADR-0129):** no force-push, and a
  required `terragrunt/apply` status, with the owner and the bot as bypass
  actors. It is created after this record's PR merges. A blog PR is unaffected,
  because `terragrunt-plan.yml`'s detect job sets the status to success
  immediately when no Terraform changed.

### 5. Removing the leaves from `noisypigeon` is never applied

The `noisypigeon` PR that deletes the six leaves, `noisypigeon.com/root.hcl` and
`noisypigeon.com/secrets.enc` **will plan destroys** against the bucket and keys
this repo now owns. Among them are this site's CNAMEs and **every mail record
for the domain**. Applying it would take the blog offline and break email.

- That PR merges through the ruleset's owner bypass. `terragrunt apply` is never
  commented on it.
- DEV-0130's "empty the old location's state" must not be followed here, because
  the old location and the new one are the same object (DEV-0163 §5).

### 6. The import merges as a merge commit

This repo already allows merge commits, so the PR merges with `--merge` once its
CI plan shows `No changes.` on all six leaves. There is no settings toggle,
unlike DEV-0163 §6. The apply is skipped: it would be a no-op, and its
auto-merge would squash the history. That auto-merge also does not work today
(noisypigeon/noisypigeon#310). The next Terraform PR here exercises the full
apply path.

## Consequences

- **This repo now runs the domain's DNS and mail configuration.** A bad
  Terraform merge here can take the site or email down. The ruleset and the
  apply gate are the controls.
- **Every blog PR now also gets a `terragrunt/apply` status.** It turns green
  without running anything, but a failing detect job would now block a blog post
  from merging.
- **Applying a Terraform PR is a hand merge until #310 is fixed.** The apply sets
  the status, and the merge has to be done manually.
- **`noisypigeon` keeps `noisypigeon.com/terraform/state/iam` indefinitely,**
  alongside `pigeon.dev`'s. LIB-0001 step 6 inherits both.
- **The imported commits cite `noisypigeon` PR numbers,** which GitHub autolinks
  against this repo. This is the same cost ADR-0154 and DEV-0163 accepted.

## Out of scope

- **Hoisting `state/iam`.** A permanent boundary for this spoke, per §1.
- **`willowgraysen.com`'s hoist.** Genuinely deferred. It needs a template minor
  bump for its Backblaze and Grafana providers (LIB-0003 `## Out of scope`).
- **Fixing the apply flow's auto-merge.** Genuinely deferred, tracked as
  noisypigeon/noisypigeon#310.

## Verification

1. **The template is equivalent:** zero differing render keys for all six
   leaves, and equal literal state keys, as in §3.
2. **The import is exact.** `diff -rq` against
   `noisypigeon@87a5089:noisypigeon.com/terraform/` differs only in
   `secrets.enc`'s new location and the excluded `state/iam/`, `cmp` of the two
   `secrets.enc` files is silent, and the tag count is unchanged.
3. **The plan is a no-op:** `No changes.` on all six leaves locally, using
   `terragrunt-run.yml`'s exact filter construction, and in this PR's CI.
4. **After `noisypigeon`'s deletion merges:**
   - `noisypigeon.com/terraform/state/iam` plans clean there.
   - `https://noisypigeon.com/` returns 200.
   - The domain's MX records still point at Proton.
   - The Bluesky and Google TXT records still resolve.
   - A trivial Terraform PR here is planned, applied and gated.
