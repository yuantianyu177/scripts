#!/usr/bin/env bash
set -euo pipefail
                
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/env.sh"

if ! command_exist zsh; then
    echo "安装zsh..."
    install_pkg zsh
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp "$ROOT_DIR/config/oh-my-zsh/.zshrc" "$HOME/.zshrc"
