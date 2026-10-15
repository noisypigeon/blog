# CLAUDE.md

Source for **noisypigeon.com**, a personal blog. Static site, built with
[Zola](https://www.getzola.org/). Split out of `noisypigeon/noisypigeon` on 2026-10-12
(ADR-0159); the scaffolding in this file arrived with COM-0000. It is a **spoke** in
LIB-0001's hub-and-spoke architecture: content plus its own deploy, consuming every reusable
asset from `noisypigeon/pigeon-lib` by pinned version (COM-0001).

This document describes the tree as it is now. Edit it in place when the tree changes — it is not
a history. The changelogs are the history.

## Layout

```
CHANGELOG.md                    one line per merged PR, by CI -- see "Changelog" below
.lib-version                    the pigeon-lib ref everything below consumes
.mise.toml                      zola version, build tasks, theme-fetch hook
fetch-lib.sh                    clones pigeon-lib into .lib-src/ at /.lib-version
docs/adr/                       decision records, COM-NNNN -- see "Decision records"
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
.github/workflows/              thin callers into pigeon-lib, plus root-changelog -- see "CI"
```

`web/themes/`, `web/public/`, and `/.lib-src/` are generated and gitignored. Nothing
commits into them.

## Where the dependencies are

**Nothing is vendored in this repo.** Its dependencies live elsewhere, which is the single most
important thing to know before changing anything:

| What | Where | How it gets here |
| --- | --- | --- |
| Zola 0.23.6 | pinned in `.mise.toml` | `mise install` |
| The theme (`zola-site`) | `noisypigeon/pigeon-lib`, at `zola-site/` | `fetch-lib.sh` clones pigeon-lib to `/.lib-src/` at the ref `/.lib-version` pins; that clone's `resolve-theme.sh` then materializes `web/themes/zola-site` at the version `config.toml` pins |
| CI job bodies | `noisypigeon/pigeon-lib`, at `.github/workflows/` | reusable workflows, called at the `workflows/vX.Y.Z` tag `/.lib-version` names |
| `root-changelog.sh` | `noisypigeon/pigeon-lib`, at `.github/scripts/` | run out of `/.lib-src/` by `root-changelog.yml` |

There are two independent pins. `/.lib-version` decides which library code runs; bump it, and
the `@workflows/…` refs in both callers, to take a hub change — never track a branch (LIB-0001
invariant 2). `[extra] theme_version` in `web/config.toml` (currently `"1.2.0"`) decides which
theme version `resolve-theme.sh` materializes, from the `zola-site/v<version>` tag. `"main"`
would instead symlink the clone's live `zola-site/`.

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
  tag is the first match of `web/` → `blog`, `docs/adr/` → `adr`, `.github/` → `ci`, else `repo`.
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

## CI

Two workflows are thin callers into `pigeon-lib`, so **that is where their behavior is
defined.** They hold only what cannot live in another repo — triggers, permissions, concurrency,
path filters, and the merged-only gate.

- `noisypigeon-com-pages.yml` → `zola-site-pages.yml`. Builds `web/` and deploys to GitHub Pages
  on pushes to `main` under `web/**`. It has to live here: `actions/deploy-pages` always deploys
  the *calling* repo's Pages site.
- `blog-changelog.yml` → `pigeon-lib`'s `blog-changelog.yml`, with `src_dir: web` and
  `changelog_path: web/CHANGELOG.md`. Writes the long form and digest on a merged `web/**` PR,
  then dispatches the Pages deploy. `root_changelog_tag` stays empty, so it never writes the root
  file.

The third, `root-changelog.yml`, carries its own job body — fetch the library, derive the tag,
run `.lib-src/.github/scripts/root-changelog.sh` — like `pigeon.dev`'s copy. Making it a hub
reusable is tracked in noisypigeon/noisypigeon#306.

This repo cuts no releases and has no `release:*` labels; every versioned asset is in
`pigeon-lib`. A change spanning the hub and this repo is two PRs, hub first, then a pin bump.

## Commits and PRs

[Conventional Commits](https://www.conventionalcommits.org/), with an optional scope and the PR
number appended by squash merge: `feat(blog): add a post (#12)`. Tooling assumes the prefix — the
digest-title generator strips `^[a-z]+(\([^)]+\))?: ` — so it is not merely style.

## Decision records

This repo's ADRs live in `docs/adr/`, as `COM-NNNN-<slug>.md`, numbered from `0000`
within that directory. `COM-0000` opened the domain and bootstrapped this repo; `COM-0001`
made it a content-only spoke. Read them before changing the build, the CI wiring, or the repo
layout; if a change would contradict one, write a new ADR rather than silently diverging.

The domain was prefixed `NPC-` until COM-0001 re-prefixed it. `NPC-NNNN` in older prose —
here, in `pigeon-lib`'s `LIB-` records and in `pigeon.dev`'s `DEV-` records — is an alias for
the same `COM-` record and is never rewritten. The records were filed in `noisypigeon/pigeon.dev`
until LIB-0001 invariant 5 made each repo own its own decisions and DEV-0161 moved them here;
`COM-0000`'s pre-move git history stays in that repo.

Filing one, by hand:

- **Number**: max+1 within `docs/adr/`.
- **Filename and H1 agree**: `COM-0002-<slug>.md` holds `# COM-0002: <title>`.
- **Author is always** `Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).`
- **Sections**: `## Context` / `## Decision` / `## Consequences` / `## Out of scope`,
  optionally then `## Verification`. No YAML frontmatter, and no index.
- Cite `COM-NNNN` for this domain, `DEV-NNNN` for `pigeon.dev`'s and `LIB-NNNN` for
  `pigeon-lib`'s. Bare `ADR-NNNN` in older prose means the `DEV-` corpus.
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
