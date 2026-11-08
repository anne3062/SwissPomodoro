#!/usr/bin/env bash
# Builds and tests the package. This is what CI should run.
# A full Xcode installation is required: SwiftUI's @State/@Bindable macros are
# not shipped with the CommandLineTools toolchain.
set -euo pipefail

cd "$(dirname "$0")/.."

DEVELOPER_DIR_PATH="$(xcode-select -p)"
if [[ "$DEVELOPER_DIR_PATH" != *Xcode*.app* ]]; then
  echo "error: full Xcode is required, but the active developer directory is:" >&2
  echo "       $DEVELOPER_DIR_PATH" >&2
  echo "       Run: sudo xcode-select -s /Applications/Xcode.app" >&2
  exit 1
fi

swift build
swift test
