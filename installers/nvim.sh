#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"

log_info "Detecting latest Neovim release..."

TAG=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

log_info "Latest version: v$TAG"

ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]]; then
    FILE="nvim-linux-x86_64.appimage"
elif [[ "$ARCH" == "aarch64" ]]; then
    FILE="nvim-linux-arm64.appimage"
else
    log_error "Unsupported architecture: $ARCH"
    exit 1
fi

log_info "Downloading: $FILE"

URL=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
      | grep -oP '"browser_download_url": "\K[^"]+' \
      | grep "$FILE$")

if [[ -z "$URL" ]]; then
    log_warn "AppImage not found in neovim/neovim, trying neovim/neovim-releases..."
    URL=$(curl -s "https://api.github.com/repos/neovim/neovim-releases/releases/latest" \
          | grep -oP '"browser_download_url": "\K[^"]+' \
          | grep "$FILE$")
fi

if [[ -z "$URL" ]]; then
    log_error "Failed to get AppImage download URL. This release may not have published the file yet."
    exit 1
fi

log_info "Download URL: $URL"

TMP=$(mktemp -d)
curl -L "$URL" -o "$TMP/$FILE"

sudo mv "$TMP/$FILE" /usr/local/bin/nvim
sudo chmod +x /usr/local/bin/nvim
nvim --version | head -n1
rm -rf "$TMP"

print_box "Success" "Neovim installed!
Path: /usr/local/bin/nvim"
