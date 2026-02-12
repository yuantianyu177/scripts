#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"

echo "Detecting latest Neovim release..."

# Get the latest version tag from neovim/neovim
TAG=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

echo "Latest version: $TAG"

# Select AppImage filename based on architecture
ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]]; then
    FILE="nvim-linux-x86_64.appimage"
elif [[ "$ARCH" == "aarch64" ]]; then
    FILE="nvim-linux-arm64.appimage"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "Downloading: $FILE"

# Match .appimage file, exclude .zsync
URL=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
      | grep -oP '"browser_download_url": "\K[^"]+' \
      | grep "$FILE$")

# If not found in official repo, try fallback repo
if [[ -z "$URL" ]]; then
    echo "AppImage not found in neovim/neovim, trying neovim/neovim-releases..."
    URL=$(curl -s "https://api.github.com/repos/neovim/neovim-releases/releases/latest" \
          | grep -oP '"browser_download_url": "\K[^"]+' \
          | grep "$FILE$")
fi

if [[ -z "$URL" ]]; then
    echo "Failed to get AppImage download URL. This release may not have published the file yet."
    exit 1
fi

echo "Download URL: $URL"

# Download
TMP=$(mktemp -d)
curl -L "$URL" -o "$TMP/$FILE"

# Install to /usr/local/bin/nvim
sudo mv "$TMP/$FILE" /usr/local/bin/nvim
sudo chmod +x /usr/local/bin/nvim
nvim --version | head -n1
rm -rf "$TMP"

message="Install path: /usr/local/bin/nvim"
print 0 "$message"
