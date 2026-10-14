# NPC-0000: bootstrap the `noisypigeon.com` repo and open an `NPC-`-prefixed ADR domain

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-13.
- **Status**: Accepted.

## Context

ADR-0159 hoisted `noisypigeon.com/src` out of `noisypigeon/noisypigeon` and into its own
`noisypigeon/noisypigeon.com` repo. It moved the site source and the two workflow callers, and
deliberately stopped there. What it did not move is everything that made the source *buildable*
and *documented*, all of which stayed behind in the monorepo.

Checked against the live tree rather than against prior prose, `noisypigeon/noisypigeon.com` at
`7875d89` contains exactly four non-content files:

```
.github/workflows/blog-changelog.yml
.github/workflows/noisypigeon-com-pages.yml
noisypigeon.com/CHANGELOG.md
noisypigeon.com/fetch-templates.sh
```

No `CLAUDE.md`, no `README.md`, no `.gitignore`, no `.mise.toml`. Three concrete problems follow.

### 1. The repo cannot be built from a clean clone

Nothing in the repo states that the site is Zola, which Zola version it wants, or that the theme
is not vendored. All three facts live only in the monorepo:

- **Zola's version is unpinned here.** `zola = "0.23.6"` is pinned in the monorepo's `.mise.toml`
  and in this repo's, but not in the site's own repo.
- **The build tasks were left behind.** The monorepo's `.mise.toml` still carries `blog-build`
  and `blog-serve`, and its trailing comment acknowledges the gap directly: *"noisypigeon.com/src
  moved to noisypigeon/noisypigeon.com repo (ADR-0159). Build tasks for the blog now live in that
  repo."* They do not. Those tasks also run
  `../../../templates/zola-site/resolve-theme.sh`, a path that does not exist in the new repo.
- **Two build artifacts have no ignore rule.** `fetch-templates.sh`'s own header comment calls
  `.templates-src/` "gitignored", but the repo has no `.gitignore` at all, so that claim is false
  where it matters most. `resolve-theme.sh` additionally materializes `src/themes/zola-site`, and
  `zola build` writes `src/public`. A single local build leaves all three as untracked noise.

### 2. The changelog is in the wrong place, and CI disagrees about where it belongs

`CHANGELOG.md` sits at `noisypigeon.com/CHANGELOG.md`, one level below the root of a repo whose
only subject *is* that blog. More than cosmetic: this repo's reusable-workflow caller asks for
behavior that no longer fits a single-site repo.

`pigeon.dev`'s reusable `blog-changelog.yml` writes **two** changelogs per merged PR:

```sh
CHANGELOG="${SITE_DIR}/CHANGELOG.md"   # the full PR body, prepended after line 5
ROOT_CHANGELOG="CHANGELOG.md"          # a "- [blog] <title> (#N)" rollup line
```

The split is a monorepo artifact. A root rollup aggregating one-liners across several workloads
earns its keep when a repo has several; `noisypigeon/noisypigeon.com` has one blog and nothing
else, so the rollup is pure redundancy — a second file restating the first in a worse format.

It is also **already broken**. The `CHANGELOG` branch has an `if [ ! -f ]` guard that creates the
file when missing; the `ROOT_CHANGELOG` branch has none, and runs `grep`/`awk` against the path
unconditionally. There is no root `CHANGELOG.md` in `noisypigeon/noisypigeon.com`, so `awk` reads
a nonexistent file and the step exits non-zero. This has not fired yet only by accident of path
filtering: the workflow triggers on `paths: ["noisypigeon.com/src/**"]`, and the sole PR merged
since the split (#1) touched only `.github/workflows/**`. The next content PR fails.

### 3. There is nowhere to record decisions about this repo

ADR-0157 moved the ADR corpus here, to `adr/infrastructure/`, and chose that path segment
specifically to leave headroom:

> `infrastructure/` leaves room for a sibling domain later without a second move.

Its `## Out of scope` then names the unexercised half:

> Any ADR for `pigeon.dev`'s own concerns (`adr/templates/` or similar). This ADR only
> establishes that `adr/<domain>/` has room for it.

`adr/` has had exactly one child ever since. The blog now has its own repo, its own CI, and —
with this ADR — its own decisions, none of which are infrastructure. This is the first exercise
of the sibling-domain pattern, and the pattern needs one thing settled before it can be used
twice: how a second domain's ADRs are identified.

## Decision

Four changes, across two PRs. `pigeon.dev` lands first, because the blog repo's caller references
a workflow input that does not exist yet and consumes the reusable workflow at `@main`.

### 1. Open `adr/noisypigeon.com/` with `NPC-`-prefixed IDs

Blog ADRs are filed here, at `adr/noisypigeon.com/NPC-NNNN-<slug>.md`, numbered from `0000` with
its own sequence: next number is max+1 **within that directory**. This file is `NPC-0000`.

The prefix is the point. `adr/infrastructure/` is a flat, continuously-numbered corpus running
`0031`–`0159` whose house style is dense cross-citation by bare `ADR-NNNN` (and often
`ADR-NNNN §N`). A second directory numbering independently from `0000` would make a bare
reference ambiguous the moment the new sequence reached `0031`; extending the global sequence
instead would avoid the collision but couple two repos' decision logs into one counter, so that
every blog ADR consumes a number from infrastructure's range and neither domain's numbering reads
as its own. Prefixing resolves both: `NPC-0000` and `ADR-0160` can never be confused, and the two
sequences advance independently.

`NPC-` is established here **as precedent for future per-repo ADR domains** — a new domain gets a
short prefix and its own sequence. Retrofitting a prefix onto `adr/infrastructure/`, or onto any
other repo's ADRs, is explicitly not part of that precedent; see `## Out of scope`.

Everything else about the house format is unchanged and deliberately so: no YAML frontmatter, an
H1 plus `Author`/`Date`/`Status` bullets, `## Context` / `## Decision` / `## Consequences` /
`## Out of scope` with an optional trailing `## Verification`, and the same `Status` vocabulary
(`Accepted.`, `Exploration.`, `Superseded by …`, `Accepted; superseded in part by …`). Per
ADR-0157 there is still no index or registry to update, and per ADR-0031 genuinely-deferred
`## Out of scope` items are filed as issues against `noisypigeon/noisypigeon`.

### 2. Teach the reusable `blog-changelog.yml` that the root rollup is optional

Two inputs and one conditional in `.github/workflows/blog-changelog.yml`:

- A new optional `changelog_path` input. Empty — the default — preserves today's
  `${site_dir}/CHANGELOG.md`; set, it names the blog's changelog outright. This is what lets a
  single-site repo keep its changelog at the root without pretending the site root is the repo
  root.
- `root_changelog_tag`'s default changes from `"blog"` to `""`, where empty means *skip the
  rollup entirely*, and the whole `ROOT_CHANGELOG` block becomes conditional on it.
- Inside that block, the missing `if [ ! -f "$ROOT_CHANGELOG" ]` guard is added, matching what
  the `CHANGELOG` branch already does. Problem 2's latent failure is fixed for any future caller
  rather than merely routed around by this repo opting out.

`site_dir` is left alone. It still resolves the daily digest at
`${site_dir}/src/content/changelog/` and pairs with the Pages caller's `src_dir`; the changelog's
location is now the one thing it no longer determines.

Flipping a default is a breaking change in general and is safe here specifically:
`noisypigeon/noisypigeon.com` is the **only** caller of this reusable workflow. The monorepo's
`.github/workflows/` is down to `interaction-limits-renew.yml`, `terragrunt-apply.yml`, and
`terragrunt-plan.yml` — its own `blog-changelog.yml` went away with the blog — and no workflow in
this repo calls it either.

### 3. Move the blog's `CHANGELOG.md` to its repo root

`noisypigeon.com/CHANGELOG.md` → `CHANGELOG.md`, with the caller passing
`changelog_path: CHANGELOG.md` and dropping `root_changelog_tag: blog`. Content moves byte-for-byte,
header included: CI splices entries with `head -n 5` / `tail -n +6`, so those five lines are
structurally load-bearing and reflowing them would start inserting entries into the middle of
prose.

### 4. Give the repo a `CLAUDE.md`, `README.md`, `.gitignore`, and `.mise.toml`

- **`.gitignore`** — `.DS_Store`, `*.env`, and the three generated paths from problem 1, each
  commented with which script writes it.
- **`.mise.toml`** — `zola = "0.23.6"` matching the other two repos; `blog-build`/`blog-serve`
  rewired to this layout (`dir = "noisypigeon.com/src"`, then `../fetch-templates.sh`, then
  `../../.templates-src/templates/zola-site/resolve-theme.sh`, then the
  `SITE_COMMIT_SHA=$(git rev-parse --short HEAD)` Zola command CI uses); and a `[hooks]
  postinstall` running `fetch-templates.sh`, so `mise install` alone leaves a fresh clone
  buildable. The `resolve-theme.sh` path works because that script resolves `REPO_ROOT` from its
  own location rather than the invoking site's — exactly the property ADR-0154 gave it for
  cross-repo use, now doing cross-repo work for a second consumer.
- **`CLAUDE.md`** — current-state only, per ADR-0157's convention for `CLAUDE.md`/`ARCHITECTURE.md`.
  Leads with where the dependencies are, since none are vendored: Zola via mise, the theme via
  `pigeon.dev`'s `templates/zola-site` fetched into `.templates-src/` and resolved against
  `[extra] theme_version`, and CI behavior defined in `pigeon.dev`'s reusable workflows rather
  than in the callers. Also carries the content conventions, the "`CHANGELOG.md` is generated,
  do not hand-edit" rule, and the ADR template plus this directory as the filing location.
- **`README.md`** — short and human-facing: it is a personal blog, where things are, quick start,
  and pointers out to `pigeon.dev`. Conventions are linked, not duplicated.

## Consequences

- **There are now two ADR ID namespaces to know.** Reading `adr/` means knowing that bare
  `ADR-NNNN` is infrastructure and `NPC-NNNN` is the blog. The prefix makes any individual
  reference unambiguous, but it is one more convention to carry, and a reader who sees `NPC-0000`
  without context has to find this file to learn what the prefix means — there is no index to
  tell them.
- **`adr-new.sh` cannot create these.** The script hardcodes `ADR_DIR_REL="adr/infrastructure"`
  and derives the next number as max+1 read from `origin/HEAD:adr/infrastructure`. It knows
  nothing about domains or prefixes, so `NPC-` ADRs are hand-written — including picking the next
  number by hand, which reintroduces exactly the collision risk the script exists to prevent.
  `0136` and `0138` are each already used twice in `adr/infrastructure/` from parallel branches;
  a hand-numbered second domain can do the same.
- **`root_changelog_tag`'s default now means the opposite of what it did.** Any future caller
  that wants the old two-changelog behavior must opt in explicitly. The sole-caller check that
  makes this safe is true as of 2026-10-13 and is not enforced by anything.
- **The blog repo's `CHANGELOG.md` keeps inherited monorepo history.** Its 24 existing entries
  are PR bodies about Terragrunt, `root.hcl`, `.sops.yaml`, and `workloads/`, linking to
  `noisypigeon/noisypigeon` PRs — none of which exist in the repo the file now sits at the root
  of. Preserved deliberately: it is the blog's real history, and rewriting published changelog
  entries to match a later directory layout would be a worse lie than the stale paths.
- **`mise install` now reaches the network.** The `postinstall` hook clones `pigeon.dev`. A fresh
  clone becomes buildable in one step, and `mise install` stops working offline.
- **Four more files to keep honest.** `CLAUDE.md` and `README.md` describe a layout that
  `## Out of scope`'s deferred flatten would change, and this family already has stale docs for
  exactly this reason — see the next section.

## Out of scope

- **Prefixing any other ADR domain, or renumbering `adr/infrastructure/`.** Permanent boundary.
  `NPC-` is precedent for *new* per-repo domains only; `adr/infrastructure/` keeps bare
  `ADR-NNNN` forever, consistent with ADR-0157's "never renumbered" rule.
- **Flattening `noisypigeon.com/src` to its repo root.** Genuinely deferred — tracked. The
  `noisypigeon.com/` directory inside a repo called `noisypigeon.com` is redundant, and removing
  it would let `site_dir` and `src_dir` collapse to `.`. Out of scope here because it touches
  both workflow callers, `fetch-templates.sh`, and every path in the two new docs, and because
  `site_dir: "."` would make the full entry and the rollup line target the same file — i.e. it
  needs decision 2 landed first regardless. ([#292](https://github.com/noisypigeon/noisypigeon/issues/292))
- **Teaching `adr-new.sh` about domains and prefixes.** Genuinely deferred — tracked. A
  `--domain`/`--prefix` flag computing max+1 within the chosen directory would remove the
  hand-numbering risk named in `## Consequences`. The script lives in `noisypigeon/noisypigeon`,
  a third repo, so it is not in either PR here. ([#293](https://github.com/noisypigeon/noisypigeon/issues/293))
- **`pigeon.dev`'s own `README.md` and `CLAUDE.md` still say ADRs live in the monorepo.**
  Genuinely deferred — tracked. `README.md` claims *"This repo's ADRs live in
  `noisypigeon/noisypigeon`, under `docs/adr/`"* and `CLAUDE.md` asserts *"This repo has no
  `docs/adr/`"*; both were falsified by ADR-0157 and are more wrong now that `adr/` has two
  children. Documented rather than fixed here to keep this PR's diff to the decision it records —
  the same call ADR-0159 made about a wrong citation it found. ([#294](https://github.com/noisypigeon/noisypigeon/issues/294))
- **Branch protection and required status checks on either repo.** Genuinely deferred — already
  raised in ADR-0157 and ADR-0159; neither repo has rulesets or protection, and this ADR adds a
  cross-repo merge-ordering constraint that nothing enforces. ([#295](https://github.com/noisypigeon/noisypigeon/issues/295))
- **`.editorconfig`, a PR template, or a `LICENSE` for the blog repo.** Permanent boundary for
  now: no repo in this family has an `.editorconfig`, and the PR body's role as published
  changelog copy is documented in `CLAUDE.md` rather than enforced by a template.

## Verification

1. `actionlint .github/workflows/blog-changelog.yml` in this repo passes, and the new
   `changelog_path` input name matches the blog caller's `with:` key character-for-character — a
   mismatch is a run-time "unexpected input" failure, not a lint error.
2. With this PR merged and the blog PR's branch checked out, `mise install` populates
   `.templates-src/` via the `postinstall` hook, and `mise run blog-build` produces
   `noisypigeon.com/src/public/` with `noisypigeon.com/src/themes/zola-site` a symlink into
   `.templates-src/templates/zola-site`.
3. `git status --porcelain` immediately after that build prints nothing. Any output means
   `.gitignore` missed a generated path — the exact failure mode problem 1 describes.
4. `mise run blog-serve` renders the homepage, a post, `/pages/about/`, and the changelog section
   with the theme applied.
5. `git log --follow CHANGELOG.md` in the blog repo shows history continuing across the move, and
   `noisypigeon-com-pages.yml`'s `paths:` filter is unchanged by it.
6. The first merged `noisypigeon.com/src/**` PR after both land — make it a content no-op, so a
   failure is cheap to revert — shows, in order: the changelog job succeeding; the entry
   prepended to **root** `CHANGELOG.md` after line 5; `noisypigeon.com/CHANGELOG.md` **not**
   recreated; no `- [blog]` line written anywhere in the tree; the digest at
   `noisypigeon.com/src/content/changelog/<today>-changelog.md` created or appended with its
   `title`/`description` recomputed; and `noisypigeon-com-pages.yml` dispatched and deploying.
