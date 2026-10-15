# COM-0002: flatten the ADRs to `adr/`, and call the hub's reusable root changelog

- **Author**: Willow Graysen ([@noisypigeon](https://github.com/noisypigeon)).
- **Date**: 2026-10-15.
- **Status**: Accepted.

## Context

COM-0001 left this repo with two differences from `pigeon.dev`, one of which it
recorded.

1. **The ADRs lived in `docs/adr/`.** `pigeon.dev` keeps them flat in `adr/`,
   where DEV-0161 put them. `docs/` held nothing else here, so it was one extra
   directory with a single child.
2. **`root-changelog.yml` carried its own job body.** It fetched the library,
   derived a tag from the changed paths, ran `root-changelog.sh` and pushed.
   `pigeon.dev`'s copy was identical except for its tag precedence. COM-0001's
   `## Consequences` named this as a breach of LIB-0001 invariant 1, and its
   `## Out of scope` deferred it as
   [noisypigeon/noisypigeon#306](https://github.com/noisypigeon/noisypigeon/issues/306).

The inline copy also did one rebase and one push in the `main-writer`
concurrency group, which it shared with `blog-changelog.yml`. GitHub keeps at
most one pending run per group and cancels the earlier one when a third
arrives. `pigeon-lib` lost a release to exactly that (pigeon-lib#9) and moved its
writers to separate groups with a push retry. The spokes never did.

## Decision

### 1. ADRs live flat in `adr/`

`docs/adr/` → `adr/` (#11), a pure move, as DEV-0161 did for `pigeon.dev`. The
root-changelog precedence, `CLAUDE.md`, `README.md` and the root changelog's
header followed it. `COM-0000` and `COM-0001` still say `docs/adr/`, which was
true when they were written, and they are left as filed.

### 2. `root-changelog.yml` becomes a thin caller

[pigeon-lib#14](https://github.com/noisypigeon/pigeon-lib/pull/14) added
`spoke-root-changelog.yml`, a reusable workflow that takes the tag precedence as
ordered `<ERE>=<tag>` lines (first match wins) plus a `fallback_tag`, defaulting
to `repo`. It shipped as `workflows/v1.2.0`. This repo now calls it with:

```
^web/=blog
^adr/=adr
^\.github/=ci
```

The caller keeps only what cannot live in the hub: the trigger, the merged-only
gate, permissions, concurrency and that precedence. `pigeon.dev` moved first
(pigeon.dev#24) and passes its own precedence to the same workflow. All three
workflows here are now thin callers, so invariant 1 holds without an exception
other than `fetch-lib.sh`.

### 3. The root writer gets its own concurrency group

`root-changelog.yml` moves from `main-writer` to `main-writer-rollup`, the hub's
name for the same role. `blog-changelog.yml` stays in `main-writer`. Neither can
now displace the other's pending run. The reusable retries a rejected push five
times, rebasing each time, and still fails outright on a rebase conflict.

## Consequences

- **A change to this repo's tagging is now a two-repo change only if it needs
  new mechanism.** Changing the precedence itself is still a one-line caller edit
  here. Changing how precedence is *interpreted* means a hub PR and a pin bump.
- **The two writers can now run concurrently.** A blog PR's two bot commits
  (long form and digest, then the root line) can race for `main`. The retry
  absorbs that. Before, they were serialized, at the risk of a silently dropped
  run.
- **The pin is `workflows/v1.2.0` everywhere here.** Between `v1.1.0` and `v1.2.0`
  only the new reusable was added, so `zola-site-pages.yml`, `blog-changelog.yml`
  and `resolve-theme.sh` are byte-identical to what ran before.
- **`pigeon-lib` is now the only repo in this family with `docs/adr/`.** Both
  spokes use `adr/`, and `pigeon-cli` predates the question.

## Out of scope

- **Flattening `pigeon-lib`'s or `pigeon-cli`'s `docs/adr/`.** Their call, in
  their own domains.
- **Rewriting `docs/adr/` paths in `COM-0000` and `COM-0001`, or in the root and
  long-form changelogs.** Permanent boundary. Records and history stay as filed.
- **The Terraform hoist.** Still blocked on LIB-0001 §8, as COM-0001 recorded.

## Verification

1. pigeon-lib#14's merge cut `workflows/v1.2.0`, with one `[workflows]` root line.
2. pigeon.dev#24's own merge ran the new reusable through its thin caller. The
   log shows `Rollup tag: ci`, and its root changelog gained exactly one `[ci]`
   line.
3. #11's merge, still on the inline job with the updated precedence, wrote one
   `- [adr] …` line.
4. This record's PR touches `.github/`, `.lib-version`, `CLAUDE.md` and `adr/`,
   so its merge should write exactly one `- [adr] …` line through the reusable.
   It should not run `blog-changelog`, because nothing under `web/` changes.
5. `actionlint` is clean on all three workflows, and every `@workflows/…` ref
   matches `.lib-version`.
