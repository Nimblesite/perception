# Perception builds inside an Osprey workspace [REPO-SPLIT]: ospreylang at scripts/osprey-version with
# this repository laid over it (scripts/workspace.sh) in ~/.cache/perception/workspace, outside the checkout so editors and language servers never index ospreylang. Every goal lays the workspace
# down again, so it holds this checkout's files, then runs its recipe from scripts/make/perception.mk there.
# Everyday targets have plain names; the rest start with `_`.
WORKSPACE ?= $(HOME)/.cache/perception/workspace
RUN = $(MAKE) -C "$(WORKSPACE)" -f scripts/make/perception.mk
RARE := compiler synth-proofs perception-test synth synth-headless synth-vst synth-vst-ui synth-vst-ui-headless synth-vst-spectrum synth-vst-editors daw-models daw-gpui daw-render daw-play daw-events-headless daw-playback-rate daw-profile daw-video

.PHONY: help packages studio lint test ci website _workspace $(addprefix _,$(RARE))

## help: List the targets.
help:
	@grep -h -E '^## ' Makefile | sed 's/^## //'

## studio: Install Perception Studio.app in /Applications. SONG=<project.json> opens that project after installing.
studio: _workspace
	$(RUN) studio

## lint: Check every project with warnings as errors; one warning fails.
lint: _workspace
	$(RUN) lint

## test: The canary: synth package and Studio journeys, the song renderer, and the macOS host smoke.
test: _workspace
	$(RUN) canary

## ci: The compiler at scripts/osprey-version, lint, the canary, then the website.
ci: _workspace
	$(RUN) perception-ci

## website: Build the website into src/studio/website/_site.
website: _workspace
	$(RUN) perception-website

## _workspace: Lay ospreylang, then this repository, into ~/.cache/perception/workspace.
_workspace: packages
	scripts/workspace.sh "$(WORKSPACE)"

## packages: Lay the Osprey packages the osprey.toml files name into src/osprey/packages (gitignored) at scripts/osprey-version, so the editor resolves them.
packages:
	scripts/osprey-packages.sh

## _<recipe>: Run any other recipe in scripts/make/perception.mk, e.g. `make _synth-vst` or `make _daw-profile`.
$(addprefix _,$(RARE)): _workspace
	$(RUN) $(@:_%=%)
