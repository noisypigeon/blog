# CLAUDE.md

`noisypigeon/blog` is the source for **noisypigeon.com**, a personal blog: a
Zola site under `web/`, deployed to GitHub Pages on every merge. `terraform/`
holds the DNS for noisypigeon.com and the redirects from `willowgraysen.com`
and `pigeon.dev`.

It is a spoke of `noisypigeon/library`. The theme, CI logic, modules, scripts
and decision records all live there. Don't add them here.

## Dev cycle

- Every change is a PR with a Conventional Commit title. The digest generator
  strips the `type(scope): ` prefix, so the prefix is required.
- **PR titles are published**, and so is a `web/**` PR's body, verbatim. Write
  them for a reader of the blog.
- Both changelogs are generated. Don't hand-edit `CHANGELOG.md`,
  `web/CHANGELOG.md` or the dated `web/content/changelog/` digests. The first
  five lines of `web/CHANGELOG.md` are load-bearing.
- This repo cuts no releases and has no `release:*` labels.
- Take a library change by bumping `.lib-version` and the `@workflows/vX.Y.Z`
  refs, `[extra] theme_version` in `web/config.toml`, or `root_hcl_version` in
  `spoke.hcl`. Never track a branch. For local iteration, point `LIB_SRC` at a
  library checkout.

## Content

Front matter is TOML:

```toml
+++
title = "cmd+a, zip, scatter"
date = 2026-02-07T07:14:40+00:00
slug = "cmda-zip-scatter"
description = "One sentence. Used for the listing and for social cards."

[taxonomies]
tags = ["personal-essays", "data-hoarding"]

[extra]
og_image = "/assets/images/posts/cmda-zip-scatter/img_2722.jpg"
+++
```

- Posts are `web/content/posts/NNNN-slug.md`, numbered in publication order.
  The URL comes from `slug`.
- Reuse a tag: `personal-essays`, `career`, `software-engineering`,
  `hardware-and-builds`, `travel`, `data-hoarding`, `press-and-interviews`,
  `photography`, `identity-and-transition`.
- Images go in `web/static/assets/images/posts/<post-slug>/`, with lowercased
  filenames.
- Archive posts carry
  `> 📖 **Note**: This post is from the archives. It may reflect outdated views or a [previous name](/pages/names/).`
- Old posts use raw `<figure class="attachment …">` HTML. Match it rather than
  modernizing it.

## Terraform

- Leaves are `terraform/<provider>/<module>/<instance>/`, plus the zone for
  zone-scoped Cloudflare modules. Each leaf calls one library module.
- A leaf's path is its state key. Don't move one without a state move.
- **`root.hcl` is generated. Never edit it.** Bump `root_hcl_version`, run
  `mise run terraform-prepare` and commit the diff.
- Secrets are sops files under `terraform/secrets/`. Edit one with
  `mise run secrets-edit <file>`.
- A Terraform PR is planned on the PR and applied by commenting
  `terragrunt apply`, which applies exactly that plan. If it doesn't merge
  itself, merge it by hand once `terragrunt/apply` is green. If apply says the
  plan is missing or stale, comment `terragrunt plan` to plan again, after
  rebasing if `main` changed the same leaves (LIB-0022).
- State is on R2, copied to B2 after every apply. To restore it, see library's
  `docs/runbooks/restore-terraform-state-from-b2.md`.

## Commands

- `mise install`, which also fetches the theme
- `mise run blog-serve` / `mise run blog-build`
- `mise run plan` / `mise run apply` (prefer the PR flow)
- `mise run terraform-prepare`
- `mise run fmt-terraform` / `mise run fmt-check-terraform`
- `mise run secrets-edit <file>`
