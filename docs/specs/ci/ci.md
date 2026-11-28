# Continuous integration [CI]

## Lint [CI-LINT]

Every Perception project (`src/synth`, `src/synth/tests`, `src/studio`, `src/studio/render`, `src/studio/test`) is checked with `osprey --check --warnings-as-errors`. One warning fails `make lint`, `make ci` and the CI build phase. A warning is fixed in the source. It is never silenced: no `--no-warnings`, no `[lints]` level lowered to `allow` or `info`, except where a specification sets that level ([DOC-EXPORT-EXAMPLE-REQUIRED]: applications allow `unexampled-export`; the synth package denies it).

Every Osprey source under `src/synth` and `src/studio` is formatted: `osprey fmt --check` with the compiler at `scripts/osprey-version` fails on any file it would change. `make fmt` is not a target; run `osprey fmt src/synth src/studio`.

`scripts/make/perception.mk` includes ospreylang's `Makefile`, so the two share one target namespace, and make only warns when a target is defined twice and silently runs the later recipe. A Perception target named like an ospreylang one (`lint`, `_synth_vst_build`) once swapped ospreylang's whole-workspace deslop into the lint step. `perception-lint` therefore fails on any `warning: overriding` while make reads the files.

`scripts/lint.sh` checks the rest of the checkout at pinned tool versions (through `uvx`), so a laptop and CI agree:

| Check | Tool |
|---|---|
| Every tracked file under `src` sits under a `paths` entry, so the workspace lays it and CI builds it | `git ls-files` |
| Every workflow `uses:` resolves to a published tag or branch (`astral-sh/setup-uv@v10` never existed and failed CI before any step ran) | `git ls-remote` |
| Shell scripts | shellcheck 0.11.0 |
| Python lint and format | ruff 0.15.17 |
| C, C++ and Objective-C++ format (`.clang-format`) | clang-format 23.1.5 |
| JavaScript parses | `node --check` |
| Duplication at or under `.deslop.toml`'s ceiling, which only goes down | deslop |

`make lint` runs both halves; `make ci` and the CI build phase run them before any test.

## Jobs [CI-JOBS]

Build (compile every program, lint, website) → in parallel: the canary on Linux and macOS with coverage, the synthesis proofs, and the VST3 worker on macOS ([SYNTH-HOST-VST]) → the coverage gate. `CI` is the one required check and passes only when every job does.
