---
name: code-dedup
description: Finds duplicated and dead code with deslop, then merges or deletes the worst. Use when the user says "deduplicate", "find duplicates", "remove dead code" or "DRY up".
---
# Code Dedup 🧹

1. 🔎 `deslop top-offenders` + `find-similar` ([docs](https://deslop.live/docs/for-ai/))
2. ⚖️ Merge real duplication; leave look-alikes that will diverge
3. 🗑️ Delete dead code, unused imports, stale comments now. No back-compat shims
4. 🟢 `make test` stays green; coverage never drops
