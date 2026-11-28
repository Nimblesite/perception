# AGENTS.md 🎛️

**Perception:** the transparent modular DAW in Osprey: Perception Studio (DAW + modular patch editor), song renderer, FerroUI host, Perception Modular (isolated VST3 worker), website. 🌐 <https://nimblesite.github.io/perception/>

- 🎼🚫 Music is hand-written. ❌ generate notes, patterns, arrangements or projects with a script, loop or generator
- 🎚️ `@osprey/synth` lives here (`src/synth`); `@osprey/signal_flow` stays in ospreylang
- 🧪 `make ci` = compiler, canary, website. `make test` = the canary: Studio's host-free journeys, ARC song renderer, macOS GPUI smoke
- 🖥️ Apps run headless or windowed, screenshot vs committed goldens. Windows = WinUI, sandboxed (MSIX AppContainer)
- 📜 Logging = an effect via the standard Osprey package. ❌ logs in the repo root

## 🐦 Osprey
- 🛠️ Compiler: use what's installed. 1️⃣ the VS Code extension's bundled one (`~/.vscode/extensions/nimblesite.osprey-<version>-<platform>/bin/<platform>/osprey`), 2️⃣ `brew install nimblesite/tap/osprey` (macOS/Linux) or `scoop install osprey` (Windows, [bucket](https://github.com/Nimblesite/scoop-bucket)). ❌ build ospreylang just to run a program. [Install](https://www.ospreylang.dev/docs/installation/)
- 📖 Learn it: [docs](https://www.ospreylang.dev/docs/) · [first app](https://www.ospreylang.dev/docs/my-first-app/) · [types](https://www.ospreylang.dev/docs/types/) · [functions](https://www.ospreylang.dev/docs/functions/) · [operators](https://www.ospreylang.dev/docs/operators/) · [keywords](https://www.ospreylang.dev/docs/keywords/) · [stdlib](https://www.ospreylang.dev/docs/stdlib/)
- ⚡ Effects = how Osprey does I/O and testing: [effects](https://www.ospreylang.dev/docs/effects/)
- ✅ Proofs + bug hunting: [formal verification](https://www.ospreylang.dev/docs/proofs/formal-verification/) · [hunt](https://www.ospreylang.dev/docs/hunt/)
- 🤖 For agents: [Python flavor for AI](https://www.ospreylang.dev/docs/python/for-ai/) · 📜 [language spec](https://www.ospreylang.dev/spec/) · 🏷️ [releases](https://www.ospreylang.dev/docs/releases/)
- 🎛️ Here: [audio synthesis](https://www.ospreylang.dev/docs/audio-synthesis/) · [reactive signals](https://www.ospreylang.dev/docs/reactive-signals/)

## 🏗️ Workspace
- 📍 Files keep their ospreylang paths. `scripts/workspace.sh` lays [ospreylang](https://github.com/Nimblesite/osprey) at the tag in `scripts/osprey-version` into `~/.cache/perception/workspace` (outside the checkout, so editors never index ospreylang), then this repo over it. Every make goal does that first
- 🎯 `make help` first. 3–7 everyday targets in `Makefile`; rarely used ones start with `_` (`make _synth-vst` runs that recipe from `scripts/make/perception.mk`)
- 🐤 `make test` (`perception.mk canary`) = what ospreylang's CI runs from this repo's `main` on Linux, macOS and Windows. 🔴 Canary broken → fix it here on `main` first
- 📌 Need a newer compiler → bump `scripts/osprey-version` to a released tag. ❌ Edit ospreylang files from here
- 🧾 Specs + plans live in `docs/`; cite their IDs (`// Implements [GROUP-TOPIC]`). Language specs stay in ospreylang

## 🔒 Safety
- 1️⃣ Memory safety + security first. 0️⃣ tolerance. Attack first
- 🛑 Osprey never panics, aborts or exits: every failure is `Result` or a handled effect. ❌ fake zero/empty values
- 🟥 Red = fail: every tracked program compiles
- 🧹 Run `make lint` routinely: every project checked with `--warnings-as-errors`. ⚠️ Any warning fails CI [CI-LINT]. Fix it; ❌ silence it (`--no-warnings`, `[lints]` downgrades)

## 🧪 Tests
- ✅ E2E use-case tests: many inputs, many interactions, many assertions. Unit tests only when isolation is needed
- 🧪 Test before fix. ❌ weaken, skip or delete a red test
- 💯 coverage aim; `scripts/coverage-thresholds.json` only goes ⬆️
- 🚦 CI = 3 phases, each once: build + check → tests with coverage → coverage gate. ❌ weaken gates, `if:` or timeouts

## ✍️ Code
- 🐛 Duplication + dead code = bugs. Run [deslop](https://deslop.live/docs/for-ai/)
- 📏 Files < 500 LOC, functions < 20 LOC. Pure functions, immutable types, expressions over statements
- 🧹 Osprey: drop every inferable type annotation (Hindley-Milner)
- 📦 Minimize deps. 🚫📦 No build output in git: generate, gitignore, ship as CI artifacts
- 🗺️ Data models in [typeDiagram](https://typediagram.dev/docs/language-reference.html); mermaid, ❌ ASCII art

## 🤝 Workflow
- ❌ subagents, linked worktrees, git hooks. One checkout
- ⏱️ Heavy CPU runs: `nice` + strict timeouts
- 🤖 Legwork → pi: ONLY `zai/glm-5.4` or `kimi-coding/k3.1-pro`
- 🙅 Never commit as co-author. Never merge PRs
