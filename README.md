# noisypigeon.com

My personal blog — essays, career notes, hardware builds, photography, and whatever else — at
**[noisypigeon.com](https://noisypigeon.com)**.

This repo is the content and configuration. It's a [Zola](https://www.getzola.org/) site, built
and deployed to GitHub Pages by CI on every merge.

## Quick start

```sh
mise install          # zola, plus a hook that fetches the theme
mise run blog-serve   # http://127.0.0.1:1111, live reload
mise run blog-build   # one-shot build into noisypigeon.com/src/public/
```

[mise](https://mise.jdx.dev/) pins the Zola version, so that's the only prerequisite.

## Where things are

| | |
| --- | --- |
| Posts | `noisypigeon.com/src/content/posts/` — one `NNNN-slug.md` per post, TOML front matter |
| Standalone pages | `noisypigeon.com/src/content/pages/` — about, lineage |
| Published changelog | `noisypigeon.com/src/content/changelog/` |
| Images | `noisypigeon.com/src/static/assets/images/posts/<post-slug>/` |
| Favicons, avatar, social card | `noisypigeon.com/src/static/assets/images/site/` |
| Site config, nav, theme version | `noisypigeon.com/src/config.toml` |
| Zola version and build tasks | `.mise.toml` |
| Release history | `CHANGELOG.md` (generated from PR bodies — don't hand-edit) |

## What lives elsewhere

Nothing is vendored here, so two things you might expect to find are in
**[noisypigeon/pigeon.dev](https://github.com/noisypigeon/pigeon.dev)** instead:

- **The theme** — `templates/zola-site`. Fetched into `.templates-src/` at build time by
  `noisypigeon.com/fetch-templates.sh`, never committed. Design and template changes go there.
- **The CI job bodies** — the two workflows in `.github/workflows/` here are thin callers into
  pigeon.dev's reusable workflows.

**Decision records** are also in that repo, under
[`adr/noisypigeon.com/`](https://github.com/noisypigeon/pigeon.dev/tree/main/adr/noisypigeon.com),
as `NPC-NNNN-*.md`.

## Contributing

It's a personal blog, so there's nothing to contribute to — but if you spotted a broken link or a
typo, an issue or PR is welcome.

Conventions, content format, and how to file an ADR are in [CLAUDE.md](CLAUDE.md).
