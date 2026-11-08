#!/usr/bin/env bash
# Builds SwissPomodoro and assembles a runnable, ad-hoc signed .app bundle.
# Usage: Scripts/bundle.sh [debug|release]   (default: release)
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG="${1:-release}"
APP_NAME="SwissPomodoro"
APP_DIR="$PWD/$APP_NAME.app"

swift build -c "$CONFIG"
BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BIN_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

# An ad-hoc signature is enough for local use (notifications need a signed bundle).
codesign --force --sign - "$APP_DIR"

echo "Built $APP_DIR"
echo "Run it with: open \"$APP_DIR\""
