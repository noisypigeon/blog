# noisypigeon.com

My personal blog — essays, career notes, hardware builds, photography, and whatever else — at
**[noisypigeon.com](https://noisypigeon.com)**.

This repo is the content and configuration. It's a [Zola](https://www.getzola.org/) site, built
and deployed to GitHub Pages by CI on every merge.

## Quick start

```sh
mise install          # zola, plus a hook that fetches the theme
mise run blog-serve   # http://127.0.0.1:1111, live reload
mise run blog-build   # one-shot build into web/public/
```

[mise](https://mise.jdx.dev/) pins the Zola version, so that's the only prerequisite.

## Where things are

| | |
| --- | --- |
| Posts | `web/content/posts/` — one `NNNN-slug.md` per post, TOML front matter |
| Standalone pages | `web/content/pages/` — about, lineage |
| Published changelog | `web/content/changelog/` |
| Images | `web/static/assets/images/posts/<post-slug>/` |
| Favicons, avatar, social card | `web/static/assets/images/site/` |
| Site config, nav, theme version | `web/config.toml` |
| Zola version and build tasks | `.mise.toml` |
| History | `CHANGELOG.md`, one line per change; `web/CHANGELOG.md`, full notes on blog changes (both generated — don't hand-edit) |
| Decision records | `adr/`, as `COM-NNNN-*.md` |

## What lives elsewhere

Nothing is vendored here, so two things you might expect to find are in
**[noisypigeon/pigeon-lib](https://github.com/noisypigeon/pigeon-lib)** instead, consumed at the
version `/.lib-version` pins:

- **The theme** — `zola-site/`. Fetched into `.lib-src/` at
  build time by `fetch-lib.sh`, at the version `/.lib-version` pins, never
  committed. Design and template changes go there.
- **The CI job bodies** — the deploy and blog-changelog workflows in `.github/workflows/` here are
  thin callers into pigeon-lib's reusable workflows.

## Contributing

It's a personal blog, so there's nothing to contribute to — but if you spotted a broken link or a
typo, an issue or PR is welcome.

Conventions, content format, and how to file an ADR are in [CLAUDE.md](CLAUDE.md).
