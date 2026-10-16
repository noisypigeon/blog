# COM-0007: rename the repo to `noisypigeon/blog`

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-16.
- **Status**: Accepted.

## Context

This repo is named after the domain it serves, `noisypigeon.com`. Its siblings
are named for what they are: `noisypigeon/garden` serves `noisypigeon.garden`
and is the module short-URL host (DEV-0165), and `noisypigeon/willowgraysen`
holds the `willowgraysen.com` namespace's infrastructure. This repo is the blog,
plus the zones for every domain that redirects to it (LIB-0008).

A domain name as a repo name also reads like a URL, which it isn't. Now that this
repo also holds `pigeon.dev`'s and `willowgraysen.com`'s zones, the name says less
about what's in it than ever.

The name is load-bearing in two places, both workflow dispatches by file name:

- **The hub's `template-release.yml`** runs
  `gh workflow run noisypigeon-com-pages.yml -R noisypigeon/noisypigeon.com`
  after a theme release.
- **This repo's `blog-changelog.yml`** passes `deploy_workflow:
  noisypigeon-com-pages.yml` to the hub's reusable workflow, which dispatches it
  in `github.repository`.

Everything else is keyed by repository ID, or names the domain rather than the
repo:

- the Pages site and its `noisypigeon.com` custom domain, the Actions secrets,
  the `main` ruleset and the bot token's grant;
- the state keys, which are relative to `root.hcl` (LIB-0001 invariant 4), and
  the `NOISYPIGEON_COM_*` and `ENV_CF_ZONE_ID_*` identifiers.

## Decision

### 1. The repo is `noisypigeon/blog`

Repos are named for their role. The site is still published at
`https://noisypigeon.com`, which stays the canonical identity (LIB-0008).

### 2. The Pages workflow is `blog-pages.yml`

`noisypigeon-com-pages.yml` becomes `blog-pages.yml`, with its `name` and
concurrency group, to match `garden-pages.yml`. `blog-changelog.yml`'s
`deploy_workflow` follows, and so does the hub's dispatch, which becomes
`gh workflow run blog-pages.yml -R noisypigeon/blog`. The dispatch is changed
rather than left to GitHub's rename redirect, because a workflow-dispatch POST
shouldn't depend on it.

### 3. What doesn't change

- **The `COM-` prefix.** It names the domain, and the domain is unchanged. That's
  the same reason `DEV-` stayed through garden's rename.
- **The domain, its zones and the Pages custom domain.**
- **The state and secret identifiers.**
- **Links in old posts and changelogs** to `github.com/noisypigeon/noisypigeon.com/…`.
  GitHub redirects them, and they're history.

### 4. Order

1. Rename the repo.
2. This repo's PR renames the workflow, repoints `blog-changelog.yml`, and
   updates its docs. A manual dispatch proves the deploy.
3. The hub's PR repoints `template-release.yml`. Hub releases are frozen between
   steps 2 and 3, because a theme release in that window would dispatch a file
   that no longer exists.
4. Every other repo's current-state docs name `noisypigeon/blog`.

## Consequences

- **Every repo's docs** say `noisypigeon/blog` where they name this repo, and
  `noisypigeon.com` where they name the domain.
- **The local clone's directory** keeps whatever name it had. The remote points
  at the new URL.

## Out of scope

- **Renaming the `COM-` prefix or the `NOISYPIGEON_COM_*` identifiers.** This is a
  permanent boundary, per §3.

## Verification

Recorded as each step of §4 lands.
