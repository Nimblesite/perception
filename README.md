# Perception

Perception is the transparent modular digital audio workstation written in Osprey: Perception Studio (the DAW and modular synth patch editor), its song renderer, the FerroUI desktop host, Perception Modular (the isolated VST3 worker) and the website. It moved out of [ospreylang](https://github.com/Nimblesite/osprey) in the [repository split](https://github.com/Nimblesite/osprey/blob/main/docs/plans/repo-split.md).

Website: <https://nimblesite.github.io/perception/>

📚 Specs: [index](docs/specs/README.md). 🎨 Designs: [Timeline](docs/designs/studio-timeline/README.md) and [device](docs/designs/studio-device/README.md). 🗺️ Plans: [daw](docs/plans/studio/studio.md) and [Perception Studio](docs/plans/studio/studio.md). 💬 [Messaging](docs/messaging/perception%20messaging.md). `@osprey/signal_flow` stays in ospreylang as a standard package.

## How it builds

The files keep the paths they had in ospreylang. `scripts/workspace.sh` checks ospreylang out at the tag in `scripts/osprey-version` into `~/.cache/perception/workspace` (outside the checkout, so editors never index ospreylang) and lays this repository over it, so every `osprey.toml` source root and ospreylang make fragment resolves as before. Every target does that first. The root `paths` file lists the paths this repository owns; ospreylang's CI reads it there, so it stays at the root.

| Command | What it does |
|---|---|
| `make studio` | Installs Perception Studio.app in /Applications (macOS); `SONG=<project.json>` opens a project |
| `make test` | The canary: synth package and Studio journeys, the song renderer and, on macOS, the host smoke replay |
| `make ci` | Builds the compiler at `scripts/osprey-version`, the canary, then the website |
| `make website` | Builds the website into `src/studio/website/_site` |
| `make help` | The targets. Rarely used ones start with `_`, e.g. `make _synth-vst`, `make _daw-profile` |

CI runs the three phases once each: build and check (every program compiles, the website builds), the canary on Linux and macOS with line coverage, then `scripts/coverage.mjs` gates the merged coverage of this repository's files against `scripts/coverage-thresholds.json`, which only goes up.

ospreylang pins this repository's commit in `scripts/ci/downstream.json` and runs `scripts/make/perception.mk canary` on every CI run. A change that breaks a canary is fixed here first, then the pin is bumped in the ospreylang PR.
