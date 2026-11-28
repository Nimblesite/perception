#!/usr/bin/env bash
# Builds an Osprey workspace [REPO-SPLIT]: ospreylang at the tag in scripts/osprey-version, then this
# repository laid over it at the same paths (every path its `paths` file lists). The product's recipes, its osprey.toml source
# roots and ospreylang's own make fragments then resolve as they did before the split.
# Usage: scripts/workspace.sh [workspace]. A workspace already at the tag is only overlaid.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
workspace=${1:-$HOME/.cache/perception/workspace}
tag=$(tr -d '[:space:]' < "$here/scripts/osprey-version")
# A workspace at another tag (scripts/osprey-version moved) is checked out at this one; build output stays.
if [ "$(cat "$workspace/.osprey-tag" 2>/dev/null)" != "$tag" ]; then
    # init and fetch rather than clone: CI's workspace already holds this repository under .split.
    mkdir -p "$workspace"
    git -C "$workspace" init --quiet
    git -C "$workspace" fetch --quiet --depth 1 https://github.com/Nimblesite/osprey.git "refs/tags/$tag"
    GIT_LFS_SKIP_SMUDGE=1 git -C "$workspace" -c advice.detachedHead=false checkout --quiet --force FETCH_HEAD
    echo "$tag" > "$workspace/.osprey-tag"
fi
overlay() {
    local source=$1 path paths=()
    while IFS= read -r path; do [ -n "$path" ] && paths+=("$path"); done < "$source/paths"
    for path in "${paths[@]}"; do rm -rf "${workspace:?}/${path:?}"; done
    git -C "$source" ls-files -z -- "${paths[@]}" | tar -C "$source" --null -T - -cf - | tar -C "$workspace" -xf -
}
overlay "$here"
echo "$workspace"
