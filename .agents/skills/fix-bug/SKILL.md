---
name: fix-bug
description: Fixes a bug test-first. Use when the user reports a bug, unexpected behaviour or something broken.
---
# Fix Bug 🐛

1. 🔍 Reproduce: state input → wrong output
2. 🧪 Extend the nearest E2E test with the failing case (many inputs, many assertions). ❌ new files
3. 🔴 Run it; it must fail for the right reason
4. 🔧 Fix the root cause, smallest diff
5. 🟢 Rerun the test, then `make test`
6. 📋 Report cause, fix and test
