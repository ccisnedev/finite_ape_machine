#!/bin/bash
# install.sh — Downloads and installs the latest Inquiry CLI release on Linux.
#
# Usage:
#   curl -fsSL https://www.si14bm.com/inquiry/install.sh | bash
#
# What it does:
#   1. Detects Linux x64
#   2. Downloads the latest .tar.gz from GitHub Releases
#   3. Extracts to ~/.inquiry/
#   4. Symlinks to ~/.local/bin (XDG standard, in default PATH)
#   5. Symlinks `iq` alias
#   6. Runs `inquiry target get`
#   7. Verifies with `inquiry version`

set -euo pipefail

REPO="siliconbrainedmachines/inquiry"
INSTALL_DIR="$HOME/.inquiry"
BIN_DIR="$INSTALL_DIR/bin"
ASSET_NAME="inquiry-linux-x64.tar.gz"

# ─── Platform check ──────────────────────────────────────────────────────────

ARCH=$(uname -m)
OS=$(uname -s)

if [ "$OS" != "Linux" ]; then
  echo "Error: Inquiry CLI install.sh is for Linux only. Got: $OS" >&2
  exit 1
fi

if [ "$ARCH" != "x86_64" ]; then
  echo "Error: Inquiry CLI requires x86_64. Got: $ARCH" >&2
  exit 1
fi

# ─── Fetch latest release ────────────────────────────────────────────────────

echo ">>> Fetching latest release..."
RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"
RELEASE_JSON=$(curl -fsSL -H "Accept: application/vnd.github+json" "$RELEASE_URL")

TAG=$(echo "$RELEASE_JSON" | grep -o '"tag_name":\s*"[^"]*"' | head -1 | sed 's/.*"tag_name":\s*"\([^"]*\)".*/\1/')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -o '"browser_download_url":\s*"[^"]*'"$ASSET_NAME"'"' | head -1 | sed 's/.*"browser_download_url":\s*"\([^"]*\)".*/\1/')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: No $ASSET_NAME asset found in release $TAG." >&2
  exit 1
fi

echo "    Release: $TAG"
echo "    Asset:   $ASSET_NAME"

# ─── Download and extract ────────────────────────────────────────────────────

TEMP_FILE=$(mktemp /tmp/inquiry-XXXXXX.tar.gz)

echo ">>> Downloading..."
curl -fsSL -o "$TEMP_FILE" "$DOWNLOAD_URL"

# Clean previous installation
if [ -d "$INSTALL_DIR" ]; then
  echo ">>> Removing previous installation..."
  rm -rf "$INSTALL_DIR"
fi

echo ">>> Extracting..."
mkdir -p "$INSTALL_DIR"
tar xzf "$TEMP_FILE" -C "$INSTALL_DIR"
rm -f "$TEMP_FILE"

# Make binary executable
chmod +x "$BIN_DIR/inquiry"

# ─── PATH integration ────────────────────────────────────────────────────────

# Symlink to ~/.local/bin (XDG standard, in default PATH on most distros)
LINK_DIR="$HOME/.local/bin"
LINK_PATH="$LINK_DIR/inquiry"
mkdir -p "$LINK_DIR"

if [ -L "$LINK_PATH" ] && [ "$(readlink "$LINK_PATH")" = "$BIN_DIR/inquiry" ]; then
  echo ">>> Symlink already configured: $LINK_PATH -> $BIN_DIR/inquiry"
else
  ln -sf "$BIN_DIR/inquiry" "$LINK_PATH"
  echo ">>> Symlink configured: $LINK_PATH -> $BIN_DIR/inquiry"
fi

# Create iq alias
IQ_LINK="$LINK_DIR/iq"
ln -sf "$BIN_DIR/inquiry" "$IQ_LINK"
echo ">>> Alias configured: $IQ_LINK -> $BIN_DIR/inquiry"

# Ensure ~/.local/bin is in PATH for current session
if [[ ":$PATH:" != *":$LINK_DIR:"* ]]; then
  export PATH="$LINK_DIR:$PATH"
  echo ">>> Added $LINK_DIR to PATH for this session"
else
  echo ">>> PATH already includes $LINK_DIR"
fi

# Persist PATH in shell profiles (.bashrc / .zshrc) for future sessions
# (.profile is only sourced by login shells; interactive shells need rc files)
for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$RC_FILE" ] || continue
  if ! grep -q '\.local/bin' "$RC_FILE"; then
    printf '\n# Added by Inquiry CLI installer\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$RC_FILE"
    echo ">>> Added ~/.local/bin to PATH in $(basename "$RC_FILE")"
  fi
done

# ─── Deploy and verify ───────────────────────────────────────────────────────

echo ">>> Deploying Inquiry to all targets..."
"$BIN_DIR/inquiry" target get

echo ">>> Verifying installation..."
VERSION_OUTPUT=$("$BIN_DIR/inquiry" version)
echo "    $VERSION_OUTPUT"

echo ""
echo ">>> Inquiry CLI installed successfully!"
echo "    Location: $INSTALL_DIR"
echo "    Restart your terminal to use 'inquiry' or 'iq' from any directory."
