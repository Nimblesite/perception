# Perception's targets [REPO-SPLIT]. They run from the root of an Osprey workspace: an ospreylang
# checkout with this repository's files laid over it, which `make workspace` at this repository's root
# builds and ospreylang's `make downstream` lays down. Run from the workspace root: make -f scripts/make/perception.mk <goal>.
include Makefile
DAW_MAKE = $(MAKE) -f scripts/make/perception.mk

.PHONY: compiler synth-proofs perception-ci perception-lint canary perception-test synth synth-headless synth-vst daw-models daw-gpui studio daw-render daw-play \
	daw-icon daw-events-headless daw-playback-rate daw-profile daw-video perception-website

## canary: Perception's major end-to-end checks, which ospreylang runs on every CI build
##         [REPO-SPLIT-CANARY]: the synth package journeys, Perception Studio's host-free journeys, the offline song renderer
##         compiled under ARC, and on macOS the daw replaying smoke.jsonl in the GPUI host.
##         PERCEPTION_COVERAGE=<file> writes the journeys' line coverage there for scripts/coverage.mjs.
PERCEPTION_COVERAGE ?=
canary: $(if $(filter Darwin,$(UNAME_S)),_runtime_macos_arc)
	$(if $(PERCEPTION_COVERAGE),mkdir -p $(dir $(PERCEPTION_COVERAGE)))
	$(BIN) test src/synth/tests$(if $(PERCEPTION_COVERAGE), --coverage-json $(basename $(PERCEPTION_COVERAGE))-synth.json)
	$(BIN) test src/studio/test$(if $(PERCEPTION_COVERAGE), --coverage-json $(PERCEPTION_COVERAGE))
	mkdir -p target/daw
	$(BIN) build src/studio/render --memory=arc --quiet -o target/daw/daw
	$(if $(filter Darwin,$(UNAME_S)),OSPREY_BIN="$(CURDIR)/$(BIN)" bash src/studio/run.sh --smoke)

## perception-lint: Every Perception project checked with warnings as errors, and every Osprey source formatted: one
##                  warning, one unformatted file or one target sharing an ospreylang target's name (this file
##                  includes ospreylang's Makefile, where make only warns and silently swaps the recipe) fails the
##                  build [CI-LINT]. scripts/lint.sh checks everything else.
LINT_PROJECTS := src/synth src/synth/tests src/studio src/studio/render src/studio/test
perception-lint:
	@! $(DAW_MAKE) -n -q compiler 2>&1 >/dev/null | grep "warning: overriding" || { echo "a Perception target shares an ospreylang target's name: rename it [CI-LINT]"; false; }
	$(foreach project,$(LINT_PROJECTS),nice $(BIN) --check --warnings-as-errors $(project) &&) true
	$(BIN) fmt --check src/synth src/studio

## compiler: The C runtime archives and the release osprey binary this product builds with.
compiler: _runtime
	$(COMPILER_BUILD)

## perception-ci: Every Perception check this host can run: the canary, then the website build.
perception-ci: compiler perception-lint canary perception-website

## perception-test: Perception Studio, driven by accessible label, with no host. [UI-MACHINE-TEST]
perception-test:
	$(MAKE) _app-suite SUITES=src/studio/test APP_SUITE_PREBUILT=1

## perception-website: Build Perception's website (Eleventy) into src/studio/website/_site.
perception-website:
	$(MAKE) -C src/studio/website build

## daw-models: Generate the project and editor types and project JSON field codec from daw.td using TYPEDIAGRAM_DIST.
daw-models:
	node scripts/make/osprey-schema.mjs "$(TYPEDIAGRAM_DIST)" src/studio/daw.td src/studio/src/daw_model.ospml daw
	node scripts/make/osprey-schema.mjs "$(TYPEDIAGRAM_DIST)" src/studio/daw.td src/studio/src/editor_model.ospml synth
	node scripts/make/osprey-schema.mjs "$(TYPEDIAGRAM_DIST)" src/studio/daw.td src/studio/src/project_codec.ospml daw Arrangement

## synth-vst: Verify isolated VST3 scanning and real instrument/effect processing headlessly.
synth-vst: _vst_worker_test

## synth: Add, drag and connect module nodes, then close/reopen the keyboard in a native window.
synth:
	$(DAW_MAKE) _studio_ui_test GPUI_WINDOW=

## synth-headless: The same module and dock journey through the native host without a window.
synth-headless:
	$(DAW_MAKE) _studio_ui_test GPUI_WINDOW=--headless

## _vst_worker_build: Build Perception Modular from the pinned official SDK.
.PHONY: _vst_worker_build _vst_worker_test
_vst_worker_build:
	python3 src/toolchain/hosts/synth_vst/build.py

## _vst_worker_test: Scan and process real SDK instruments/effects without a window or audio device.
_vst_worker_test:
	python3 src/toolchain/hosts/synth_vst/build.py --test

## synth-proofs: [SYNTH-DSP-PROOFS] Every Synthesis theorem, then every production FFT, spectral-frame and
##               waveshaper theorem derived from src/synth and src/studio, replays in the Osprey kernel built
##               for gc, arc and wasm32 with no axioms; each source mutation is rejected. Needs Lean (elan).
SYNTHESIS_THEOREMS := weightedOverlapAdd travelingWavePropagation additivePeriod overlapNormalizationNecessary interpolatorFactor interpolatorEndpoints interpolatorConstant zeroPulseIndices hannEndpoints
SYNTHESIS_THEOREMS += allpassMagnitude allpassRecurrence antiderivativeAverage antiderivativeOffset antiderivativeConstantCurve hannQuarterEnergy hannEighthEnergy
SYNTHESIS_THEOREMS += radixTwoSplit radixTwoUpper realBinConjugate binAdditive binHomogeneous
.PHONY: synth-proofs
synth-proofs: export SYNTHESIS_THEOREMS := $(SYNTHESIS_THEOREMS)
synth-proofs: $(PROOF_BATCH_TARGETS)
	bash scripts/proof/production-fft.sh

# The host every app links into, built in the host's own target directory, which CI caches.
GPUI_HOST_BIN := src/toolchain/hosts/gpui/target/release/osprey-gpui

# Perception Studio's editable graph, module insertion and bottom dock in the real native host.
.PHONY: _studio_ui_test
_studio_ui_test: _runtime_macos_arc
	OSPREY_BIN="$(CURDIR)/$(BIN)" bash src/studio/run.sh --bundle
	OSPREY_GPUI_APP_NAME=synth OSPREY_GPUI_TITLE="Perception Studio" OSPREY_GPUI_WINDOW=1152x756 OSPREY_GPUI_CHROME=bare python3 src/toolchain/hosts/synth_vst/build.py --design-test "$(CURDIR)/$(GPUI_HOST_BIN)" $(GPUI_WINDOW)

## _modular_ui_test: Drive Perception Modular's menu against real SDK modules and worker processes.
.PHONY: _modular_ui_test
_modular_ui_test: _runtime_macos_arc
	$(COMPILER_BUILD)
	python3 src/toolchain/hosts/synth_vst/build.py --test
	OSPREY_BIN="$(CURDIR)/$(BIN)" bash src/studio/run.sh --bundle
	python3 src/toolchain/hosts/synth_vst/build.py --studio-test "$(CURDIR)/$(GPUI_HOST_BIN)" $(STUDIO_TEST_MODE)

## daw-gpui: Open the daw's Perception Studio patch editor on the GPUI host instead of FerroUI.
##        [STUDIO-ROUTING-EDITOR] [STUDIO-ROUTING-AUDIO]
daw-gpui: _runtime_macos
	$(COMPILER_BUILD)
	OSPREY_BIN="$(CURDIR)/$(BIN)" bash src/studio/run.sh

## studio: Install Perception Studio.app in /Applications so it opens from Spotlight. Set SONG to open a project after installing.
##        [DAW-PROJECT] [STUDIO-ROUTING-TIMELINE]
studio: SONG =
studio: _runtime_macos _daw-renderer
	STUDIO_PROJECT="$(SONG)" OSPREY_BIN="$(CURDIR)/$(BIN)" bash src/osprey/packages/ferroui/scripts/studio.sh --install


## daw-render: Render a song project with the daw (a JSON piano roll, its intro recording named inside) with
##               @osprey/synth to target/daw/<project>/song.wav. SONG picks the project. Needs ffmpeg
##               and xxd; rendering is offline and slow. [SYNTH-ARRANGEMENT-PLAYER]
SONG ?= src/studio/tracks/phosphor-drift.json
SONG_DIR = target/daw/$(basename $(notdir $(SONG)))
SONG_WAV = $(SONG_DIR)/song.wav
daw-render: _daw-renderer
	target/daw/daw "$(SONG)" "$(SONG_DIR)"

# Shared song renderer for the interactive DAW and the offline bounce; ARC, as GC scans of the held mix tripled render time.
.PHONY: _daw-renderer
_daw-renderer:
	$(COMPILER_BUILD)
	mkdir -p target/daw
	$(BIN) build src/studio/render --memory=arc -o target/daw/daw

## daw-play: Play SONG's rendered WAV with afplay; it never renders (run daw-render first).
daw-play:
	@test -f "$(SONG_WAV)" || { echo "daw-play: $(SONG_WAV) is missing; run make -C src/studio daw-render"; exit 1; }
	timeout 3600 afplay "$(SONG_WAV)"

## daw-icon: Verify the macOS DAW launches from a bundle with the original Perception Studio Dock icon.
.PHONY: daw-icon
daw-icon:
	bash src/toolchain/targets/macos/tests/studio-icon.sh

## daw-events-headless: The daw's event budget on the FerroUI host, with no window: dragging a Perception Studio module
##                      and tapping Timeline lanes each answer within one 60 Hz display frame.
.PHONY: daw-events-headless
daw-events-headless: daw-icon _runtime_macos
	$(COMPILER_BUILD)
	mkdir -p target/perception-studio-app
	nice -n 10 $(BIN) src/studio --compile --target=macos -o target/perception-studio-app/libOspreyApp.a
	OSPREY_NATIVE_APP_DIR="$(CURDIR)/target/perception-studio-app" OSPREY_RUNTIME_DIR="$(CURDIR)/src/toolchain/compiler/lib" \
	OSPREY_NATIVE_ABI="$(CURDIR)/src/toolchain/compiler/runtime/native_abi.h" \
	nice -n 10 cargo test --manifest-path src/osprey/packages/ferroui/Cargo.toml --release --features desktop \
	    --test studio_events --test daw_events -- --nocapture

## daw-playback-rate: Verify cold live rendering at 1.5× real time and report start time and longest block gap.
DAW_RATE_RENDERER ?= target/daw-profile/rate-renderer
DAW_RATE_SONG ?= src/studio/tracks/codex-version.json
DAW_RATE_FROM ?= 0
DAW_RATE_BEATS ?= 2
.PHONY: daw-playback-rate
daw-playback-rate: _runtime_macos
	$(COMPILER_BUILD)
	mkdir -p target/daw-profile
	nice -n 10 $(BIN) build src/studio/render --memory=arc -o "$(DAW_RATE_RENDERER)"
	node scripts/make/daw-playback-rate.mjs "$(DAW_RATE_RENDERER)" "$(DAW_RATE_SONG)" "$(DAW_RATE_FROM)" "$(DAW_RATE_BEATS)"

## daw-profile: Measure the daw and say where the time goes ([DAW-PERF]): milliseconds per kind of user action on
##              every page, then a 1 ms sample of the Timeline, Mix and Patch pages and of the song renderer, each
##              attributed to Osprey functions and the runtime calls they make. Reports in target/daw-profile.
.PHONY: daw-profile
daw-profile: _runtime_macos
	$(COMPILER_BUILD)
	bash scripts/make/daw-profile.sh

## daw-video: The daw in a real window, clicked and dragged like a user: a note's velocity and a Space send on the
##            Timeline, a Delay added and wired into a patch and auditioned, a send, bus and reverb on Mix, then
##            Play renders the edited bars. Each step must change the screen and Play must render audio. Writes target/daw-video/perception-studio-journey.mp4 (with the bars as
##            its soundtrack) and the step screenshots. Needs screen recording and accessibility access. [DAW-VIDEO]
.PHONY: daw-video
daw-video: _runtime_macos
	$(DAW_MAKE) _daw-renderer
	bash scripts/make/daw-video.sh target/daw-video

.PHONY: synth-vst-ui synth-vst-ui-headless
## synth-vst-ui: Perception Modular's real discovery, parameter and routing journey in a native window.
synth-vst-ui:
	$(DAW_MAKE) _modular_ui_test

## synth-vst-ui-headless: The same Perception Modular journey without a window, using real worker processes.
synth-vst-ui-headless:
	$(DAW_MAKE) _modular_ui_test STUDIO_TEST_MODE=--headless

## synth-vst-spectrum: Measure the real Dragonfly or TAL output in the built Perception Studio host.
.PHONY: synth-vst-spectrum
synth-vst-spectrum:
	node src/toolchain/hosts/synth_vst/spectrum.mjs "$(VST3_FOLDER)" "$(or $(VST3_CASE),dragonfly)" "$(or $(VST3_UI),headless)"

## synth-vst-editors: Edit installed VST3 parameters and open, focus, close and reopen each native editor.
.PHONY: synth-vst-editors
synth-vst-editors:
	node src/toolchain/hosts/synth_vst/editors.mjs "$(VST3_FOLDER)"
