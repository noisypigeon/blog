#!/usr/bin/env bash
# Clones noisypigeon/library into /.lib-src/ at /.lib-version. Set LIB_SRC to use your own checkout.
set -euo pipefail

LIB_REPO_URL="${LIB_REPO_URL:-https://github.com/noisypigeon/library.git}"
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
  echo "::error::$REPO_ROOT/.lib-version is empty; it must name a library ref" >&2
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
  echo "::error::library has no ref $LIB_REF (from .lib-version)" >&2
  exit 1
fi
git -C "$LIB_SRC" checkout --quiet --detach "$LIB_REF"

echo "Library resolved -> ${LIB_SRC#"$REPO_ROOT"/} @ ${LIB_REF} ($(git -C "$LIB_SRC" rev-parse --short HEAD), $(git -C "$LIB_SRC" tag | wc -l | tr -d ' ') tags)"
