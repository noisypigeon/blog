#!/usr/bin/env bash
# Materializes the library repo -- noisypigeon/pigeon-lib, which owns
# terraform/*, zola-site/ and the shared CI since LIB-0002 -- into a gitignored
# /.lib-src/ at this repo's root, checked out at the version this repo pins in
# /.lib-version. This site reads two things out of it: zola-site/resolve-theme.sh
# for the theme, and .github/scripts/root-changelog.sh when CI writes a
# changelog entry.
#
# Pinned, not branch-tracking: LIB-0001 invariant 2 says a spoke consumes
# versions, never branches. The previous version of this script did
# `reset --hard origin/HEAD`, which is exactly the branch-tracking that
# invariant forbids.
#
# Tags are always fetched regardless of the pinned ref, because
# resolve-theme.sh materializes a theme version by tag out of this clone.
#
# Blobless (--filter=blob:none) because the common case only needs the tag
# graph and a handful of files; blobs are fetched on demand when a pinned
# `git archive` actually needs them.
#
# Set LIB_SRC to point at your own checkout of that repo (e.g. when iterating
# on the theme and this site together) and this script leaves it completely
# alone -- it only ever manages the default path.
set -euo pipefail

LIB_REPO_URL="${LIB_REPO_URL:-https://github.com/noisypigeon/pigeon-lib.git}"
REPO_ROOT="$(git rev-parse --show-toplevel)"

if [ -n "${LIB_SRC:-}" ]; then
  if [ ! -d "$LIB_SRC/zola-site" ]; then
    echo "::error::LIB_SRC=$LIB_SRC has no zola-site/ directory" >&2
    exit 1
  fi
  echo "Library resolved -> $LIB_SRC (caller-supplied, left as-is)"
  exit 0
fi

LIB_REF="$(tr -d '[:space:]' < "$REPO_ROOT/.lib-version")"
if [ -z "$LIB_REF" ]; then
  echo "::error::$REPO_ROOT/.lib-version is empty; it must name a pigeon-lib ref" >&2
  exit 1
fi

LIB_SRC="$REPO_ROOT/.lib-src"

if [ -d "$LIB_SRC/.git" ]; then
  git -C "$LIB_SRC" fetch --quiet --tags --prune --force origin
else
  rm -rf "$LIB_SRC"
  git clone --quiet --filter=blob:none "$LIB_REPO_URL" "$LIB_SRC"
fi

if ! git -C "$LIB_SRC" rev-parse --verify --quiet "$LIB_REF" >/dev/null; then
  echo "::error::pigeon-lib has no ref $LIB_REF (from .lib-version)" >&2
  exit 1
fi
git -C "$LIB_SRC" checkout --quiet --detach "$LIB_REF"

echo "Library resolved -> ${LIB_SRC#"$REPO_ROOT"/} @ ${LIB_REF} ($(git -C "$LIB_SRC" rev-parse --short HEAD), $(git -C "$LIB_SRC" tag | wc -l | tr -d ' ') tags)"
