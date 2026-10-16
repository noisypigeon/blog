# Changelog

One line per PR across this whole repo, sectioned by date, newest first. Every
merged PR gets exactly one line here; a PR that changes the blog additionally
gets its full PR body in [`web/CHANGELOG.md`](web/CHANGELOG.md). DEV-0160 is the
contract, adopted here by COM-0001.

Entry format is `- [<tag>] <PR title> ([#N](pr-url))`, where `<tag>` is one of:

- `blog` — the Zola site under `web/` (`noisypigeon.com/src/` before #8)
- `terraform` — the domain's Terraform: `terraform/`, `root.hcl`, `spoke.hcl`, `.sops.yaml` (from COM-0003)
- `adr` — decision records under `adr/` (`docs/adr/` before #11)
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

## 2026-10-16

- [terraform] feat(terraform): turn the Scaleway provider off and drop its secrets (COM-0005) ([#28](https://github.com/noisypigeon/noisypigeon.com/pull/28))
- [terraform] chore(terraform): destroy this domain's Scaleway project ([#27](https://github.com/noisypigeon/noisypigeon.com/pull/27))
- [terraform] chore(terraform): destroy the old Scaleway state bucket ([#26](https://github.com/noisypigeon/noisypigeon.com/pull/26))
- [terraform] chore(terraform): let the old Scaleway state bucket be destroyed with its contents ([#25](https://github.com/noisypigeon/noisypigeon.com/pull/25))
- [adr] docs: link the B2 state restore runbook and COM-0004's deferred issues ([#24](https://github.com/noisypigeon/noisypigeon.com/pull/24))
- [ci] ci: pin pigeon-lib's reusable workflows at workflows/v1.5.3 ([#23](https://github.com/noisypigeon/noisypigeon.com/pull/23))
- [ci] ci: pin pigeon-lib's reusable workflows at workflows/v1.5.2 ([#22](https://github.com/noisypigeon/noisypigeon.com/pull/22))
- [terraform] feat(terraform): move this domain's Terraform state to Cloudflare R2, backed up to B2 (COM-0004) ([#21](https://github.com/noisypigeon/noisypigeon.com/pull/21))

## 2026-10-15

- [terraform] feat(terraform): add the R2 state bucket and its B2 backup (LIB-0007) ([#19](https://github.com/noisypigeon/noisypigeon.com/pull/19))
- [ci] ci: pin pigeon-lib's reusable workflows at workflows/v1.5.1 ([#20](https://github.com/noisypigeon/noisypigeon.com/pull/20))
- [terraform] chore(terraform): take root.hcl v2.0.0, with providers named in spoke.hcl ([#18](https://github.com/noisypigeon/noisypigeon.com/pull/18))
- [terraform] refactor(terraform): rename the leaves to LIB-0004's layout ([#17](https://github.com/noisypigeon/noisypigeon.com/pull/17))
- [terraform] refactor(terraform): move the DNS leaves onto cloudflare/dns-record ([#16](https://github.com/noisypigeon/noisypigeon.com/pull/16))
- [repo] docs: list willowgraysen.com's RUN- ADR domain ([#15](https://github.com/noisypigeon/noisypigeon.com/pull/15))
- [terraform] fix(terraform): point the state bucket output at terraform/secrets.enc ([#14](https://github.com/noisypigeon/noisypigeon.com/pull/14))
- [terraform] feat(com-0003)!: run noisypigeon.com's Terraform from this repo ([#13](https://github.com/noisypigeon/noisypigeon.com/pull/13))
- [adr] docs(com-0002): call pigeon-lib's reusable root changelog, and record the adr/ flatten ([#12](https://github.com/noisypigeon/noisypigeon.com/pull/12))
- [adr] docs: move decision records to adr/ ([#11](https://github.com/noisypigeon/noisypigeon.com/pull/11))
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
