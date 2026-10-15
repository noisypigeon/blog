# Changelog

One line per PR across this whole repo, sectioned by date, newest first. Every
merged PR gets exactly one line here; a PR that changes the blog additionally
gets its full PR body in [`web/CHANGELOG.md`](web/CHANGELOG.md). DEV-0160 is the
contract, adopted here by COM-0001.

Entry format is `- [<tag>] <PR title> ([#N](pr-url))`, where `<tag>` is one of:

- `blog` — the Zola site under `web/` (`noisypigeon.com/src/` before #8)
- `adr` — decision records under `docs/adr/`
- `ci` — `.github/` workflows
- `repo` — anything else (root docs, `.mise.toml`, `fetch-lib.sh`)

All of them are written by `root-changelog.yml`, which runs on every merged PR
with no exceptions. It calls `root-changelog.sh` out of the pinned library
rather than a vendored copy, and that script inserts below the marker at the end
of this header — keep that line where it is.

Entries for #1–#8 were backfilled by hand when this file was created, tagged by
the same precedence the workflow applies. History older than this repo — the
blog's years inside `noisypigeon/noisypigeon` — is in `web/CHANGELOG.md`.

<!-- entries below; newest first -->

## 2026-10-15

- [adr] docs(com-0001): make noisypigeon.com a content-only spoke, and re-prefix to COM- ([#10](https://github.com/noisypigeon/noisypigeon.com/pull/10))
- [blog] ci: give every change a one-line changelog entry ([#9](https://github.com/noisypigeon/noisypigeon.com/pull/9))
- [blog] refactor: move the site source to web/ ([#8](https://github.com/noisypigeon/noisypigeon.com/pull/8))
- [ci] ci: pin pigeon-lib at workflows/v1.1.0 ([#7](https://github.com/noisypigeon/noisypigeon.com/pull/7))

## 2026-10-14

- [repo] Follow pigeon.dev's DEV- prefix rename ([#6](https://github.com/noisypigeon/noisypigeon.com/pull/6))

## 2026-10-13

- [adr] Adopt the NPC ADR domain into this repo ([#5](https://github.com/noisypigeon/noisypigeon.com/pull/5))
- [blog] Consume pigeon-lib at a pinned version ([#4](https://github.com/noisypigeon/noisypigeon.com/pull/4))
- [blog] fix(blog): correct typos in four archive posts ([#3](https://github.com/noisypigeon/noisypigeon.com/pull/3))
- [ci] chore: bootstrap repo docs, dev setup, and a root changelog ([#2](https://github.com/noisypigeon/noisypigeon.com/pull/2))

## 2026-10-12

- [ci] feat: add GitHub Pages and changelog deployment workflows ([#1](https://github.com/noisypigeon/noisypigeon.com/pull/1))
