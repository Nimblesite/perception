---
name: spec-check
description: Finds disagreements between specs, code, tests and docs, then brings them into line. Use when the user says "check specs", "spec audit" or "verify specs".
---
# Spec Check 📐

1. 🧾 Collect the spec IDs cited here (`[GROUP-TOPIC]`); specs live in `docs/specs/` (language specs in ospreylang)
2. 🔗 Every ID cited in code has a test citing it, and resolves to a spec section
3. ⚔️ Disagreement → fix the stale side; a language-spec change goes to ospreylang
4. 📋 Report each mismatch and its fix
