#!/usr/bin/env bash
# [CI-LINT] Every check of this checkout that is not the Osprey compiler's: any finding fails. Tools run
# at pinned versions through uvx, so a laptop and CI agree byte for byte. Needs uv, node and deslop.
# Usage: scripts/lint.sh (from anywhere).
set -euo pipefail
cd "$(dirname "$0")/.."
tool() { uvx --quiet --from "$1" "${@:2}"; }
tracked() { git ls-files -- "$@"; }
mapfile -t shell < <(tracked '*.sh')
mapfile -t python < <(tracked '*.py')
mapfile -t native < <(tracked '*.c' '*.cpp' '*.h' '*.mm')
mapfile -t scripts < <(tracked '*.mjs' ':!src/studio/website')

echo "==> Every tracked source is laid into the workspace (paths)"
unlaid=$(tracked src | grep -v -E "^($(paste -sd'|' paths))(/|$)" || true)
[ -z "$unlaid" ] || { echo "not under any paths entry, so never built or tested:"; echo "$unlaid"; exit 1; }

echo "==> Every action a workflow uses resolves to a published tag or branch"
grep -rhoE 'uses: [^./][^ ]*@[^ ]+' .github | sort -u | while read -r _ ref; do
  repo=$(cut -d/ -f1,2 <<<"${ref%@*}")
  git ls-remote --exit-code "https://github.com/$repo" "refs/tags/${ref#*@}" "refs/heads/${ref#*@}" >/dev/null || { echo "unresolvable: $ref"; exit 1; }
done

echo "==> Shell"
tool shellcheck-py==0.11.0.1 shellcheck "${shell[@]}"

echo "==> Python"
tool ruff==0.15.17 ruff check "${python[@]}"
tool ruff==0.15.17 ruff format --check "${python[@]}"

echo "==> C, C++ and Objective-C++"
tool clang-format==23.1.5 clang-format --dry-run --Werror "${native[@]}"

echo "==> JavaScript"
for file in "${scripts[@]}"; do node --check "$file"; done

echo "==> Duplication (.deslop.toml gate)"
deslop . --nohtml --nojson --output target/deslop-report --log-to-console --log-level error --no-color
