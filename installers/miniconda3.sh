#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/env.sh"
source "$ROOT_DIR/lib/file.sh"

OS_TYPE="$(uname -s)"
ARCH_TYPE="$(uname -m)"

if [[ "$OS_TYPE" != "Darwin" && "$OS_TYPE" != "Linux" ]]; then
    log_error "Unsupported OS: $OS_TYPE"
    exit 1
fi

if [[ "$ARCH_TYPE" != "x86_64" && "$ARCH_TYPE" != "arm64" && "$ARCH_TYPE" != "aarch64" ]]; then
    log_error "Unsupported architecture: $ARCH_TYPE"
    exit 1
fi

if [[ "$OS_TYPE" == "Linux" ]]; then
    OS="Linux"
else
    OS="MacOSX"
fi

BASE_URL="https://mirrors.nju.edu.cn/anaconda/miniconda/"
INSTALLER="Miniconda3-latest-$OS-$ARCH_TYPE.sh"

log_info "Downloading Miniconda3..."
wget "${BASE_URL}${INSTALLER}" -O conda.sh || {
  log_error "Failed to download Miniconda3"
  exit 1
}

log_info "Installing Miniconda3..."
bash conda.sh -b -u -p "$HOME/.local/share/miniconda3" && rm conda.sh

RC_FILE=$(get_login_shell_rc_file)
content='# miniconda3
export PATH="$HOME/.local/share/miniconda3/bin:$PATH"
source "$HOME/.local/share/miniconda3/bin/activate"'
append_if_not_exists "$RC_FILE" "$content"

log_info "Configuring Conda mirror sources..."
cat <<EOF > "$HOME/.condarc"
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirror.nju.edu.cn/anaconda/pkgs/main
  - https://mirror.nju.edu.cn/anaconda/pkgs/r
  - https://mirror.nju.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirror.nju.edu.cn/anaconda/cloud
  pytorch: https://mirror.nju.edu.cn/anaconda/cloud
EOF

print_box "Success" "Miniconda3 installed!
Install path: $HOME/.local/share/miniconda3
Updated: $RC_FILE
Mirror config: $HOME/.condarc"
