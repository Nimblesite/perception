---
name: submit-pr
description: Opens a pull request after CI passes locally. Use when the user asks to submit, create or open a PR.
disable-model-invocation: true
---
# Submit PR 🚀

1. 🚦 Run `ci-prep` first; ❌ open a PR with red steps
2. 🌿 Never PR from `main`; branch first
3. 📝 `gh pr create`: title = the change; body = what, why, how tested, spec IDs
4. 👀 Watch the run to green. ❌ merge: that's the user's call
