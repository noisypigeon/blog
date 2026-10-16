# CLAUDE.md

Source for **noisypigeon.com**, a personal blog. Static site, built with
[Zola](https://www.getzola.org/). Split out of `noisypigeon/noisypigeon` on 2026-10-12
(ADR-0159); the scaffolding in this file arrived with COM-0000. It is a **spoke** in
LIB-0001's hub-and-spoke architecture: content plus the infrastructure that serves it, consuming
every reusable asset from `noisypigeon/pigeon-lib` by pinned version (COM-0001, COM-0003).

This document describes the tree as it is now. Edit it in place when the tree changes — it is not
a history. The changelogs are the history.

## Layout

```
CHANGELOG.md                    one line per merged PR, by CI -- see "Changelog" below
.lib-version                    the pigeon-lib ref everything below consumes
.mise.toml                      tool versions, build and terraform tasks, theme-fetch hook
.sops.yaml                      sops/age recipient for terraform/secrets.enc
fetch-lib.sh                    clones pigeon-lib into .lib-src/ at /.lib-version
root.hcl                        GENERATED Terragrunt root -- see "Terraform"; never edit
spoke.hcl                       root.hcl template version + this spoke's instance values
terraform/                      the domain's Terraform leaves -- see "Terraform"
  secrets.enc                   sops/age-encrypted dotenv
adr/                            decision records, COM-NNNN -- see "Decision records"
web/
  CHANGELOG.md                  full PR bodies for blog changes, by CI; not published
  config.toml                   the only build config
  content/
    _index.md                   homepage
    posts/                      54 posts, NNNN-slug.md
    pages/                      about.md, lineage.md
    changelog/                  published changelog digests
  static/
    manifest.json, robots.txt
    assets/images/posts/<post-slug>/
    assets/images/site/         avatar, favicons, social preview
.github/workflows/              thin callers into pigeon-lib -- see "CI"
```

`web/themes/`, `web/public/`, `/.lib-src/` and every `.terragrunt-cache/` are generated and
gitignored. Nothing commits into them. `root.hcl` is generated too, but committed — see
"Terraform".

## Where the dependencies are

**Nothing is vendored in this repo.** Its dependencies live elsewhere, which is the single most
important thing to know before changing anything:

| What | Where | How it gets here |
| --- | --- | --- |
| Zola 0.23.6 | pinned in `.mise.toml` | `mise install` |
| The theme (`zola-site`) | `noisypigeon/pigeon-lib`, at `zola-site/` | `fetch-lib.sh` clones pigeon-lib to `/.lib-src/` at the ref `/.lib-version` pins; that clone's `resolve-theme.sh` then materializes `web/themes/zola-site` at the version `config.toml` pins |
| CI job bodies | `noisypigeon/pigeon-lib`, at `.github/workflows/` | reusable workflows, called at the `workflows/vX.Y.Z` tag `/.lib-version` names |
| `root-changelog.sh` | `noisypigeon/pigeon-lib`, at `.github/scripts/` | run out of `/.lib-src/` by `root-changelog.yml` |
| Terragrunt `root.hcl` | `noisypigeon/pigeon-lib`, at `terragrunt/root-hcl/` | `resolve-root-hcl.sh` copies it at the version `spoke.hcl` pins; committed here |
| Terraform 1.16.3, Terragrunt 1.1.6, sops 3.13.3 | pinned in `.mise.toml` | `mise install` |

There are three independent pins. `/.lib-version` decides which library code runs; bump it, and
the `@workflows/…` refs in every caller, to take a hub change — never track a branch (LIB-0001
invariant 2). `[extra] theme_version` in `web/config.toml` (currently `"1.2.0"`) decides which
theme version `resolve-theme.sh` materializes, from the `zola-site/v<version>` tag. `"main"`
would instead symlink the clone's live `zola-site/`. `root_hcl_version` in `spoke.hcl` decides
which `terragrunt/root-hcl/v<version>` template `root.hcl` is generated from.

To change the theme, the CI, or any script, send a PR to `noisypigeon/pigeon-lib`, then bump the
pin here. Nothing in this repo can do it. For local iteration across both, point `LIB_SRC` at a
`pigeon-lib` checkout and `fetch-lib.sh` leaves it alone. `fetch-lib.sh` is the one script this
repo keeps — a spoke cannot fetch its own fetcher.

## Working on it

```sh
mise install          # installs zola; the postinstall hook fetches the theme
mise run blog-serve   # http://127.0.0.1:1111
mise run blog-build   # writes web/public/
```

Both tasks re-fetch the library and re-resolve the theme first, so they are safe to run after a
pin bump. `git status` should be clean after a build; if it isn't, `.gitignore` is missing a
generated path.

## Content conventions

Front matter is **TOML** (`+++`), not YAML:

```toml
+++
title = "cmd+a, zip, scatter"
date = 2026-02-07T07:14:40+00:00          # RFC 3339, with offset
slug = "cmda-zip-scatter"
description = "One sentence. Used for the listing and for social cards."
# aliases = ["pages/names"]               # optional, for moved URLs

[taxonomies]
tags = ["personal-essays", "data-hoarding"]

[extra]
og_image = "/assets/images/posts/cmda-zip-scatter/img_2722.jpg"
+++
```

- **Posts** are `content/posts/NNNN-slug.md`, numbered in publication order. `slug` in the front
  matter is what the URL uses; the `NNNN-` prefix only orders the directory.
- **Tags** come from an existing vocabulary — `personal-essays`, `career`,
  `software-engineering`, `hardware-and-builds`, `travel`, `data-hoarding`,
  `press-and-interviews`, `photography`, `identity-and-transition`. Reuse one rather than coining
  a near-duplicate; each one is a published taxonomy page.
- **Images** go to `static/assets/images/posts/<post-slug>/`, filenames lowercased and sanitized,
  referenced as `/assets/images/posts/<post-slug>/<file>`.
- **Archive posts** (anything predating this site) carry the standard banner:
  `> 📖 **Note**: This post is from the archives. It may reflect outdated views or a [previous name](/pages/names/).`
- Post bodies contain raw `<figure class="attachment …">` HTML, a Jekyll-era carryover. Match the
  surrounding markup when editing an old post rather than modernizing it in passing.
- `content/changelog/` has two naming schemes on purpose: `0001-`–`0004-` are hand-written
  platform-migration announcements, and `YYYY-MM-DD-changelog.md` digests are written by CI.
  Don't hand-edit the dated ones.

## Changelog

Both changelogs are **generated — do not hand-edit them.** This is DEV-0160's contract, adopted
by COM-0001:

- **Root `CHANGELOG.md`** — exactly one line per merged PR, every PR, written by
  `root-changelog.yml`: `- [<tag>] <PR title> ([#N](url))` under a `## YYYY-MM-DD` heading. The
  tag is the first match of `web/` → `blog`, `terraform/`/`root.hcl`/`spoke.hcl`/`.sops.yaml` →
  `terraform`, `adr/` → `adr`, `.github/` → `ci`, else `repo`.
  The `<!-- entries below; newest first -->` marker is where entries go; the script refuses to
  write without it.
- **`web/CHANGELOG.md`** — for PRs touching `web/**`, `blog-changelog.yml` prepends the PR body
  verbatim, then appends a line to that day's digest under `web/content/changelog/` and
  dispatches the Pages deploy.

Consequences:

1. **The PR title is always published copy, and a blog PR's body is too.** Write both for a
   reader of the blog, not for a reviewer — the title lands in the root changelog and, for blog
   PRs, in the public digest.
2. **The first five lines of `web/CHANGELOG.md` are load-bearing.** CI splices entries with
   `head -n 5` / `tail -n +6`. Reflow that header and entries start landing in the middle of
   prose.

`web/CHANGELOG.md` entries before 2026-10-13 describe monorepo concerns (Terragrunt,
`workloads/`, `root.hcl`) and link to `noisypigeon/noisypigeon` PRs. That is inherited history,
deliberately left as-is.

## Terraform

`terraform/` follows LIB-0004's layout, `terraform/<provider>/<module>/<instance>/`, where
`<provider>/<module>` is exactly the pigeon-lib module the leaf calls. Seven leaves:

| Leaf | What it is |
| --- | --- |
| `cloudflare/dns-record/github-pages` | the apex and `www` CNAMEs that put this site online |
| `cloudflare/dns-record/proton` | Proton Mail's MX, SPF, DKIM, DMARC and verification records — this domain's email |
| `cloudflare/dns-record/bluesky` | the Bluesky handle's `_atproto` TXT record |
| `cloudflare/dns-record/google-search` | Google Search Console site verification |
| `cloudflare/bucket/terraform-state` | this domain's Terraform state bucket, on R2 (COM-0004) — its own state lives in it; never destroy it |
| `backblaze/bucket/terraform-state-backup` | the versioned offsite copy of the R2 state |
| `backblaze/api-key/terraform-state-backup` | the list-and-write-only key `state-backup.yml` copies with |

A leaf calls exactly one pigeon-lib module (with `for_each` if it needs several instances); a new
leaf goes under that module's coordinate, with a kebab-case `<instance>` naming what it is for. The
leaves were hoisted from `noisypigeon/noisypigeon` with their history (COM-0003) and renamed into
this layout by moving their state (LIB-0004 §3). Each leaf's state key is
`terraform/<provider>/<module>/<instance>/terraform.tfstate` in this domain's own R2 bucket, because
`root.hcl` sits at this repo's root (LIB-0001 invariant 4). **Moving `root.hcl` or a leaf changes
its state key** — don't, without LIB-0004 §3's runbook: `state pull`/`push` via a worktree of
`main`, then `state rm` everything at the old key. And run Terragrunt with `TG_TF_PATH=terraform`
(mise sets it): an OpenTofu apply re-addresses providers in state to `registry.opentofu.org`,
which later breaks `moved` blocks.

- **`root.hcl` is generated — never edit it.** It is pigeon-lib's `terragrunt/root-hcl` template
  at the version `spoke.hcl` pins (`root_hcl_version`), copied by
  `.lib-src/.github/scripts/resolve-root-hcl.sh` and committed. Committed rather than ignored
  because Terragrunt's git filter plans inside git worktrees, which only hold tracked files
  (LIB-0003). CI runs the resolver with `--check` and fails on drift. To take a template change,
  bump `root_hcl_version`, run `mise run terraform-prepare`, commit the diff.
- **`spoke.hcl`** holds the template version, `state_bucket_secret`
  (`NOISYPIGEON_COM_R2_TERRAFORM_STATE_BUCKET_NAME`), `state_backend = "cloudflare"` (LIB-0007,
  COM-0004) and the `providers` map (LIB-0005) — `cloudflare` on for every leaf, `backblaze` for
  `terraform/backblaze/` only. Scaleway is off: this domain has had no Scaleway resources since
  COM-0005.
- **State is on Cloudflare R2, backed up to Backblaze B2** (COM-0004). R2 has no object
  versioning, so `state-backup.yml` copies every state object to a versioned B2 bucket after each
  apply and daily. Its B2 key can list and write, never read or delete. A restore needs the admin
  B2 key, by hand, through B2's native API: follow pigeon-lib's
  [`docs/runbooks/restore-terraform-state-from-b2.md`](https://github.com/noisypigeon/pigeon-lib/blob/main/docs/runbooks/restore-terraform-state-from-b2.md).
  Here the backup bucket is `com-000mqm-terraform-state-backup`, in B2's `ca-east-006` region.
- **Secrets** are in `terraform/secrets.enc` (sops/age, dotenv; `.sops.yaml` has the recipient).
  Edit with `mise run secrets-edit`. CI decrypts with the `SOPS_AGE_KEY` repo secret. The R2 S3
  keys (`CLOUDFLARE_R2_*`) are made by hand in the Cloudflare dashboard — there is no Terraform
  resource for them — scoped to the state bucket with *Object Read & Write*.

A Terraform PR is planned by `terragrunt-plan.yml` and applied by commenting `terragrunt apply` on
it (`terragrunt-apply.yml`; ADR-0124/0129). A successful apply sets the `terragrunt/apply` status
`main`'s ruleset requires. It then tries to squash-merge the PR and currently fails to
(noisypigeon/noisypigeon#310), so merge it by hand once the status is green. Never merge a
Terraform PR any other way. A content-only PR is unaffected: `terragrunt-plan.yml`'s detect job
sets `terragrunt/apply` to success straight away.

## CI

All six workflows are thin callers into `pigeon-lib`, so **that is where their behavior is
defined.** They hold only what cannot live in another repo — triggers, permissions, concurrency,
path filters, and the merged-only gate.

- `noisypigeon-com-pages.yml` → `zola-site-pages.yml`. Builds `web/` and deploys to GitHub Pages
  on pushes to `main` under `web/**`. It has to live here: `actions/deploy-pages` always deploys
  the *calling* repo's Pages site.
- `blog-changelog.yml` → `pigeon-lib`'s `blog-changelog.yml`, with `src_dir: web` and
  `changelog_path: web/CHANGELOG.md`. Writes the long form and digest on a merged `web/**` PR,
  then dispatches the Pages deploy. `root_changelog_tag` stays empty, so it never writes the root
  file.

- `terragrunt-plan.yml` / `terragrunt-apply.yml` → `pigeon-lib`'s `terragrunt-detect.yml` and
  `terragrunt-run.yml`; see "Terraform" above. `terragrunt-apply.yml`'s `backup` job then calls
  `state-backup.yml`, even after a failed apply.
- `state-backup.yml` → `pigeon-lib`'s `state-backup.yml`, daily and on `workflow_dispatch`:
  copies the R2 state to its B2 backup (COM-0004).
- `root-changelog.yml` → `pigeon-lib`'s `spoke-root-changelog.yml`, passing this repo's tag
  precedence (`web/` → `blog`, `terraform/`, `root.hcl`, `spoke.hcl` or `.sops.yaml` →
  `terraform`, `adr/` → `adr`, `.github/` → `ci`, else `repo`). Writes the one root line on every merged PR, in its own `main-writer-rollup`
  concurrency group; the reusable retries a rejected push (COM-0002).

`main` has a ruleset (COM-0003, copied from `noisypigeon`'s ADR-0129): no force-push, and the
`terragrunt/apply` status is required. This repo cuts no releases and has no `release:*` labels; every versioned asset is in
`pigeon-lib`. A change spanning the hub and this repo is two PRs, hub first, then a pin bump.

## Commits and PRs

[Conventional Commits](https://www.conventionalcommits.org/), with an optional scope and the PR
number appended by squash merge: `feat(blog): add a post (#12)`. Tooling assumes the prefix — the
digest-title generator strips `^[a-z]+(\([^)]+\))?: ` — so it is not merely style.

## Decision records

This repo's ADRs live flat in `adr/`, as `COM-NNNN-<slug>.md`, numbered from `0000`
within that directory. `COM-0000` opened the domain and bootstrapped this repo; `COM-0001`
made it a content-only spoke;
`COM-0002` flattened them to `adr/` and thinned the last inline workflow; `COM-0003` hoisted
the domain's Terraform here; `COM-0004` moved its state to R2 with a B2 backup; `COM-0005`
retired its Scaleway resources. Read them before changing the build, the CI wiring, or the repo
layout; if a change would contradict one, write a new ADR rather than silently diverging.

The domain was prefixed `NPC-` until COM-0001 re-prefixed it. `NPC-NNNN` in older prose —
here, in `pigeon-lib`'s `LIB-` records and in `pigeon.dev`'s `DEV-` records — is an alias for
the same `COM-` record and is never rewritten. The records were filed in `noisypigeon/pigeon.dev`
until LIB-0001 invariant 5 made each repo own its own decisions and DEV-0161 moved them here;
`COM-0000`'s pre-move git history stays in that repo.

Filing one, by hand:

- **Number**: max+1 within `adr/`.
- **Filename and H1 agree**: `COM-0004-<slug>.md` holds `# COM-0004: <title>`.
- **Author is always** `Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).`
- **Sections**: `## Context` / `## Decision` / `## Consequences` / `## Out of scope`,
  optionally then `## Verification`. No YAML frontmatter, and no index.
- Cite `COM-NNNN` for this domain, `DEV-NNNN` for `pigeon.dev`'s, `LIB-NNNN` for
  `pigeon-lib`'s and `RUN-NNNN` for `willowgraysen.com`'s. Bare `ADR-NNNN` in older prose means the `DEV-` corpus.
- Genuinely-deferred `## Out of scope` items get a GitHub issue against
  `noisypigeon/noisypigeon` (ADR-0031); permanent design boundaries do not.
- Nothing indexes ADRs, and `adr-new.sh` in the monorepo cannot create these. Branch
  `adr/com-NNNN-<slug>`, commit `docs(com-NNNN): <title>`.

**Template** — no YAML front matter; an H1, three bullets, then the sections:

```markdown
# COM-NNNN: <title>

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: YYYY-MM-DD.
- **Status**: Accepted.

## Context

## Decision

## Consequences

## Out of scope
```

`## Verification` is optional and goes last, for ADRs whose outcome is checkable.

`Status` is one of: `Accepted.`, `Exploration.` (a design spike recording a direction and its open
questions, not something landed), `Superseded by [COM-NNNN](COM-NNNN-slug.md).`, or
`Accepted; superseded in part by [COM-NNNN](…) (<which part, specifically>).`

House style, worth matching: state findings as facts verified against the live tree rather than
against prior prose; say plainly what a decision reverses; classify every `## Out of scope` bullet
as either a permanent boundary or genuinely deferred; and in `## Consequences`, name concrete
costs rather than restating the benefits.
