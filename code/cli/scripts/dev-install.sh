#!/bin/bash
# dev-install.sh — Builds and installs Inquiry CLI from source.
#
# Usage (from repo root or scripts/):
#   ./code/cli/scripts/dev-install.sh
#
# What it does:
#   1. Runs build.sh (compile + package assets)
#   2. Copies build/ → ~/.inquiry/ (same layout as install.sh)
#   3. Creates symlinks in ~/.local/bin (inquiry + iq)
#
# Requires: Dart SDK in PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$CLI_ROOT/build"
INSTALL_DIR="$HOME/.inquiry"
BIN_DIR="$INSTALL_DIR/bin"
LINK_DIR="$HOME/.local/bin"

# ─── Build ────────────────────────────────────────────────────────────────────

echo ">>> Building from source..."
bash "$SCRIPT_DIR/build.sh"

# ─── Install ──────────────────────────────────────────────────────────────────

if [ -d "$INSTALL_DIR" ]; then
  echo ">>> Removing previous installation..."
  rm -rf "$INSTALL_DIR"
fi

echo ">>> Installing to $INSTALL_DIR..."
mkdir -p "$BIN_DIR"
cp "$BUILD_DIR/bin/inquiry" "$BIN_DIR/inquiry"
chmod +x "$BIN_DIR/inquiry"
cp -r "$BUILD_DIR/assets" "$INSTALL_DIR/assets"

# ─── Symlinks ─────────────────────────────────────────────────────────────────

mkdir -p "$LINK_DIR"
ln -sf "$BIN_DIR/inquiry" "$LINK_DIR/inquiry"
ln -sf "$BIN_DIR/inquiry" "$LINK_DIR/iq"
echo ">>> Symlinks: $LINK_DIR/inquiry, $LINK_DIR/iq"

# Ensure ~/.local/bin is in PATH for current session
if [[ ":$PATH:" != *":$LINK_DIR:"* ]]; then
  export PATH="$LINK_DIR:$PATH"
  echo ">>> Added $LINK_DIR to PATH for this session"
fi

# ─── Verify ───────────────────────────────────────────────────────────────────

echo ">>> Verifying..."
"$BIN_DIR/inquiry" version

echo ""
echo ">>> Installed from source successfully!"
echo "    Location: $INSTALL_DIR"
