#!/usr/bin/env bash
# [DAW-MACOS-ICON] The ordinary DAW launch and the Finder entry use the same branded bundle.
set -euo pipefail
repo=$(cd "$(dirname "$0")/../../../../.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/studio-icon.XXXXXX")
work=$(cd "$work" && pwd)
trap 'rm -rf "$work"' EXIT
export STUDIO_PREBUILT=1 STUDIO_BINARY="$work/record host" STUDIO_BUNDLE_DIR="$work/build"
cat > "$STUDIO_BINARY" <<'HOST'
#!/usr/bin/env bash
printf '%s\n' "$0" "$OSPREY_NATIVE_TITLE" "$@"
HOST
chmod +x "$STUDIO_BINARY"
song="$repo/src/studio/tracks/codex-version.json"
script="$repo/src/osprey/packages/ferroui/scripts/studio.sh"
STUDIO_PROJECT="$song" bash "$script" > "$work/launch"
bundle="$STUDIO_BUNDLE_DIR/Perception Studio.app"
contents="$bundle/Contents"
host="$contents/MacOS/ferroui-osprey-native"
[[ $(head -1 "$work/launch") == "$host" ]] || { echo 'Perception Studio launched outside its .app bundle' >&2; exit 1; }
plist="$contents/Info.plist"
plutil -lint "$plist" >/dev/null
value() { /usr/libexec/PlistBuddy -c "Print :$1" "$plist"; }
[[ $(value CFBundlePackageType) == APPL && $(value CFBundleName) == "Perception Studio" ]]
entry="$contents/MacOS/$(value CFBundleExecutable)"
iconutil -c iconset "$contents/Resources/$(value CFBundleIconFile)" -o "$work/PerceptionStudio.iconset"
logo="$repo/src/osprey/packages/signal_flow/skins/prism/logo.png"
# Normalise PNG metadata and compare the actual 1024px logo supplied to the Dock.
for image in "$logo" "$work/PerceptionStudio.iconset/icon_512x512@2x.png"; do
    sips -s format bmp "$image" --out "$work/$(basename "$image").bmp" >/dev/null
done
cmp "$work/logo.png.bmp" "$work/icon_512x512@2x.png.bmp"
(cd / && "$entry") > "$work/finder"
cmp "$work/launch" "$work/finder"

# [DAW-MACOS-INSTALL] The installed entry opens from any folder, with its own resources and renderer.
export STUDIO_APPLICATIONS_DIR="$work/Applications" STUDIO_RENDERER="$work/record host"
bash "$script" --install
installed="$STUDIO_APPLICATIONS_DIR/Perception Studio.app/Contents"
[[ -x "$installed/MacOS/daw" && -r "$installed/Resources/signal_flow.machine.json" ]]
[[ -r "$installed/Resources/skins/prism/logo.png" ]]
[[ $(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$installed/Info.plist") == "Perception Studio" ]]
(cd / && HOME="$work/home" "$installed/MacOS/PerceptionStudio") > "$work/installed"
default="$work/home/Library/Application Support/Perception Studio/codex-version.json"
cmp "$song" "$default"
grep -Fx -- "$default" "$work/installed"
cache="$work/home/Library/Caches/Perception Studio/daw"
grep -Fx -- "$cache" "$work/installed"
[[ $(readlink "$cache") == "$installed/MacOS/daw" ]]
(cd / && HOME="$work/home" "$installed/MacOS/PerceptionStudio" --project "$song") > "$work/explicit"
grep -Fx -- "$song" "$work/explicit"
printf 'kept\n' > "$default"
bash "$script" --install
(cd / && HOME="$work/home" "$installed/MacOS/PerceptionStudio") >/dev/null
grep -Fx kept "$default"
