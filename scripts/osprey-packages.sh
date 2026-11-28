#!/usr/bin/env bash
# Lays the Osprey standard packages Perception's osprey.toml source roots name into src/osprey/packages
# (gitignored), at the ospreylang tag in scripts/osprey-version, so the compiler and the editor's
# language server resolve them in this checkout as they do in the workspace [REPO-SPLIT]. Only these
# packages are fetched (a sparse checkout): nothing else of ospreylang lands in the repository.
# Usage: scripts/osprey-packages.sh. Does nothing when the packages are already at the tag.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
tag=$(tr -d '[:space:]' < "$here/scripts/osprey-version")
dest=$here/src/osprey/packages
packages=(native signal_flow graphics json uitest manager/core)
[ "$(cat "$dest/.tag" 2>/dev/null)" = "$tag" ] && exit 0
fetch=$(mktemp -d)
trap 'rm -rf "$fetch"' EXIT
git -C "$fetch" init --quiet
git -C "$fetch" sparse-checkout set --no-cone "${packages[@]/#//src/osprey/packages/}"
git -C "$fetch" fetch --quiet --depth 1 --filter=blob:none https://github.com/Nimblesite/osprey.git "refs/tags/$tag"
GIT_LFS_SKIP_SMUDGE=1 git -C "$fetch" -c advice.detachedHead=false checkout --quiet FETCH_HEAD
rm -rf "$dest"
mkdir -p "$(dirname "$dest")"
mv "$fetch/src/osprey/packages" "$dest"
echo "$tag" > "$dest/.tag"
