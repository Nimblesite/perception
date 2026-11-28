PORT ?= 8080

.PHONY: build dev _clean

## build: Build the Perception Eleventy site into _site/, installing dependencies first if missing.
build:
	@test -d node_modules || npm install
	npm run build

## dev: Build and serve the site with live reload on http://localhost:$(PORT).
dev:
	@test -d node_modules || npm install
	npx eleventy --serve --watch --port=$(PORT)

## _clean: Remove the generated _site/.
_clean:
	npm run clean
