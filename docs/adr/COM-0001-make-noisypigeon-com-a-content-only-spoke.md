# COM-0001: make `noisypigeon.com` a content-only spoke, and re-prefix this domain `COM-`

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-15.
- **Status**: Accepted.

## Context

LIB-0001 §7 step 4 gives this repo "the same two steps" as `pigeon.dev`: the
content split, then the Terraform hoist. DEV-0162 records what the content split
actually did for `pigeon.dev`. It pinned the hub, kept two thin workflows, renamed
the site root to `web/`, and kept DEV-0160's root-changelog contract. The hoist is
still blocked on LIB-0001 §8's `state/iam` problem for every spoke.

Measured against `pigeon.dev` after DEV-0162, this repo already consumed the hub
by pin (#4, through `.lib-version` and `fetch-lib.sh`). It differed in five ways,
all checked against the live tree at `860d008`.

1. **The site root was `noisypigeon.com/src/`.** That is a directory named after
   its own repo, the same redundancy DEV-0161 and DEV-0162 removed from
   `pigeon.dev`. COM-0000 deferred this flatten as
   [noisypigeon/noisypigeon#292](https://github.com/noisypigeon/noisypigeon/issues/292).
2. **`fetch-lib.sh` lived under `noisypigeon.com/`.** `pigeon.dev` keeps it at the
   root, and DEV-0162's `## Out of scope` named the mismatch.
3. **The pin was `workflows/v1.0.2`.** The hub had reached `v1.0.7`.
4. **The root changelog did not follow DEV-0160.** Root `CHANGELOG.md` held full
   PR bodies and was written only for PRs touching `noisypigeon.com/src/**`, so
   #1, #2, #5 and #6 left no record at all. COM-0000 chose that shape on purpose,
   on the grounds that a single-site repo wants one changelog. That held while
   the only alternative was the monorepo's cross-workload rollup. It stops
   holding once the family's convention is DEV-0160's two-tier contract: one line
   per PR at the root, and the full body in the changed unit's own
   `CHANGELOG.md`.
5. **The hub could not describe a `web/` root.** `blog-changelog.yml` hardcoded
   the digest at `${site_dir}/src/content/changelog/`, so any site root without
   a `src/` beneath it was inexpressible.

`CLAUDE.md` and `README.md` had also drifted. They placed the CI job bodies in
`pigeon.dev` at `@main` and said `theme_version` was `"main"`. They also put this
repo's ADRs in `pigeon.dev/adr/noisypigeon.com/`. `CLAUDE.md` had two
`## Decision records` sections that contradicted each other.

## Decision

### 1. Teach the hub a site root first

[pigeon-lib#13](https://github.com/noisypigeon/pigeon-lib/pull/13) added an
optional `src_dir` input to `blog-changelog.yml`, which names the Zola root
directly. It uses the same vocabulary as `zola-site-pages.yml`, and the digest
goes to `<src_dir>/content/changelog/`. `site_dir` became optional and is
unchanged when passed. The job refuses a call that passes both, or neither, or
`src_dir` without a `changelog_path`. It shipped additively as `workflows/v1.1.0`.

That is the hub-first, spoke-second order DEV-0162 describes. The pin bump (#7)
landed alone, ahead of the rename, so any regression from the hub's `v1.0.3`–`v1.1.0`
changes would show up on its own.

### 2. Rename the site root to `web/`, not the repo root

`noisypigeon.com/src` → `web/` (#8) was a pure rename plus the path edits it
forces. `fetch-lib.sh` moved to the repo root alongside it and now matches
`pigeon.dev`'s copy, apart from the header lines that list what each site reads
from the hub.

#292 proposed the repo root itself. `web/` is the deliberate choice instead, for
parity: both spokes now pass the same `src_dir`, `fetch_script` and
`theme_script` to the same reusable workflows, and their `.mise.toml` tasks
differ only in what they run before `zola`. A site at `.` would also have mixed
Zola's `content/`, `static/` and `themes/` with `docs/`, `.github/` and the root
changelog.

### 3. Adopt DEV-0160: one root line per PR, the long form beside the site

The blog's PR-body changelog moved to `web/CHANGELOG.md`, with its five-line
header byte-identical, since `blog-changelog.yml` splices on `head -n 5`. That
is the unit changelog in DEV-0160's terms. Zola ignores loose files in the site
root, so it is not published.

A new root `CHANGELOG.md` gets exactly one line per merged PR from a new
`root-changelog.yml`, copied from `pigeon.dev`'s and run against the pinned
`root-changelog.sh`. Its precedence is `web/` → `blog`, `docs/adr/` → `adr`,
`.github/` → `ci`, and everything else → `repo`. The root file was backfilled by
hand for #1–#8 (#9).

`blog-changelog.yml` keeps `root_changelog_tag` empty. `root-changelog.yml` is
therefore the root file's only writer, with no stand-down predicate to keep in
sync, which is the collision LIB-0002 recorded when two writers shared one.

### 4. Re-prefix this domain `NPC-` → `COM-`

This repo's ADRs are `COM-NNNN` from here on. The `.com` is what this repo has
that its sibling spokes do not, and the repo's own corpus is a fresh start under
it. `NPC-0000` is renamed to `COM-0000`: the file and its H1 change, and the body
stays exactly as filed.

The method is DEV-0160's for `ADR-` → `DEV-`. Existing in-text `NPC-NNNN`
citations, in this repo's history and in the `LIB-` and `DEV-` corpora, are
**grandfathered as aliases** and never rewritten. The living docs that teach the
prefix (`CLAUDE.md` and `README.md` here, in `pigeon-lib` and in `pigeon.dev`)
say `COM-`.

This reverses a permanent boundary. COM-0000's `## Out of scope` reserved
prefixing as "precedent for *new* per-repo domains only", and its target was
retrofitting a prefix onto someone else's corpus. Re-prefixing this domain's own
single record crosses the letter of that boundary, in the same way DEV-0160
crossed ADR-0157's "never renumbered".

## Consequences

- **A blog PR now produces two bot commits.** `blog-changelog.yml` writes the
  long form and the digest, then `root-changelog.yml` writes the root line. Both
  share the `main-writer` concurrency group and rebase before pushing. The order
  between them is not fixed, and neither depends on the other.
- **A content PR whose diff also touches `.github/` is tagged `blog`.** It is
  first match wins, one tag per PR, as DEV-0160 specifies. #9 itself is an
  example: a changelog-contract PR filed as `[blog]` because it moved a file
  under `web/`.
- **`NPC-` and `COM-` name the same domain.** A reader meeting `NPC-0000` in
  LIB-0001 or DEV-0160 has to know that it is now `COM-0000`. This record and
  the `CLAUDE.md` files are the only places that say so. That is the cost
  DEV-0160 already accepted for `ADR-`.
- **`root-changelog.yml` is a workflow body in a spoke.** So is `pigeon.dev`'s.
  Two near-identical copies, differing only in precedence, are what LIB-0001
  invariant 1 exists to prevent.
- **#292 is closed by a different answer than it asked for.** The redundancy it
  named is gone, but the site sits at `web/`, not at the repo root.

## Out of scope

- **The Terraform hoist (LIB-0001 step 4's second half).** Blocked on LIB-0001
  §8, as for `pigeon.dev`. This repo ends with `web/`, no `terraform/` and no
  `root.hcl`; `noisypigeon.com/terraform/**` stays in `noisypigeon/noisypigeon`.
- **A reusable `root-changelog.yml` in the hub.** Genuinely deferred — tracked as
  [noisypigeon/noisypigeon#306](https://github.com/noisypigeon/noisypigeon/issues/306).
  It needs the tag precedence expressed as an input, and both spokes repinned.
- **`noisypigeon/noisypigeon`'s own docs still citing `noisypigeon.com/src`.**
  Genuinely deferred to LIB-0001 step 6, which rewrites that repo as content
  only. Its ADRs keep those paths as filed.
- **Rewriting `NPC-` citations anywhere.** Permanent boundary. They are aliases,
  as bare `ADR-NNNN` is for the `DEV-` corpus.
- **Deleting any tag, or branch protection.** Permanent boundaries, inherited
  from DEV-0154 and from the run of ADRs since DEV-0157 respectively.

## Verification

1. `workflows/v1.1.0` was tagged and released by `template-release.yml` on
   pigeon-lib#13's merge, with exactly one `[workflows]` root line.
2. The rename was proven inert before merging. `web/` was built with
   `SITE_COMMIT_SHA` pinned, and so was `noisypigeon.com/src` on `main`. `diff -r`
   of the two output trees printed nothing, across 66 pages. `git status
   --porcelain` was clean after `mise run blog-build`, and `shellcheck` and
   `actionlint` were clean.
3. On #8's merge, `blog-changelog` succeeded through `src_dir`, writing
   `web/content/changelog/2026-10-15-changelog.md`. No `noisypigeon.com/`
   directory was recreated. The dispatched Pages deploy succeeded, and `/`,
   `/posts/cmda-zip-scatter/` and `/changelog/` returned 200, the last showing
   the new digest line.
4. On #9's merge, both writers succeeded. The root file got exactly one
   `- [blog] …` line, the long form landed in `web/CHANGELOG.md` after line 5,
   and `git log --follow web/CHANGELOG.md` reaches back across the move to
   `noisypigeon/noisypigeon#289`.
5. This record's merge should write one `- [adr] …` root line and no long-form
   entry, since it touches nothing under `web/`.
6. `git grep -n 'NPC-'` in this repo hits only `COM-0000`'s body, this record,
   `web/CHANGELOG.md` history, and `CLAUDE.md`'s note explaining the alias.
   `README.md` and every workflow are clean.
