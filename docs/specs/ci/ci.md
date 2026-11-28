# Continuous integration [CI]

## Lint [CI-LINT]

Every Perception project (`src/synth`, `src/synth/tests`, `src/studio`, `src/studio/render`, `src/studio/test`) is checked with `osprey --check --warnings-as-errors`. One warning fails `make lint`, `make ci` and the CI build phase. A warning is fixed in the source. It is never silenced: no `--no-warnings`, no `[lints]` level lowered to `allow` or `info`, except where a specification sets that level ([DOC-EXPORT-EXAMPLE-REQUIRED]: applications allow `unexampled-export`; the synth package denies it).
