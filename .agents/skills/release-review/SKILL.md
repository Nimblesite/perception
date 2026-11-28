---
name: release-review
description: Adversarial review of this branch against main, hunting regressions, memory-safety holes and weakened tests. Use for "release review", "adversarial review" or "regression review".
---
# Release Review 🕵️

1. 📊 `git diff origin/main...HEAD --stat`; read each changed file beside its old version
2. 🔒 Memory safety first: bounds, lifetimes, GC vs ARC, FFI, untrusted input
3. 🚨 Every removed guard, error path or default is a suspect. Osprey never panics
4. 🧪 Weakened tests are findings: deleted tests, dropped assertions, lowered thresholds, looser goldens
5. ✅ Confirm each finding: input → wrong output. Drop the unproven
6. 📋 Report severity first, plus what you did and didn't review. ❌ run full CI
