---
name: ci-prep
description: Runs this repo's CI locally and fixes what fails. Use before pushing, when CI is red, or when the user says "fix ci". Pass --failing to start from the GitHub logs.
---
# CI Prep 🚦

1. 🔴 `--failing` → `gh run view <id> --log-failed`; read every line, note file, line, error
2. 📖 Read `.github/workflows/*.yml` in full. ❌ assume the steps
3. 🏃 Run each step locally in order: `make ci`. Fix, rerun, move on
4. 🪟 A step this host can't run (Windows, Postgres, Chromium) → say so, run the nearest equivalent
5. 🔧 Fix the code. ❌ suppressions, skipped tests, dropped assertions, weaker gates
6. 📋 Report each step: pass / fail / fixed, and whether it's ready to push
