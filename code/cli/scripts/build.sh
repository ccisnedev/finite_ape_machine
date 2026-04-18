#!/bin/bash
# build.sh — Compiles ape CLI and packages assets for distribution (Linux).
#
# Output structure:
#   build/
#     bin/ape
#     assets/
#       agents/ape.agent.md
#       skills/memory-read/SKILL.md
#       skills/memory-write/SKILL.md

set -euo pipefail

CLI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$CLI_ROOT/build"

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
  rm -rf "$BUILD_DIR"
fi

# Create build directories
mkdir -p "$BUILD_DIR/bin"

# Compile
echo ">>> Compiling ape..."
cd "$CLI_ROOT"
dart compile exe bin/main.dart -o "$BUILD_DIR/bin/ape"

# Copy assets
echo ">>> Copying assets..."
cp -r "$CLI_ROOT/assets" "$BUILD_DIR/assets"

echo ">>> Build complete."
echo "    Binary: $BUILD_DIR/bin/ape"
echo "    Assets: $BUILD_DIR/assets"
