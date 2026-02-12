#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/env.sh"

if ! command_exists zsh; then
    echo "Installing zsh..."
    install_pkg zsh > /dev/null
fi

echo "Installing oh-my-zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
echo "Installing plugins..."
if [[ "$(uname)" == "Darwin" ]]; then
    SED_CMD="sed -i ''"
else
    SED_CMD="sed -i"
fi

add_zsh_plugin() {
    local new_plugin="$1"
    plugin=$(grep -n '^plugins=(.*)$' ~/.zshrc | cut -d':' -f2)
    line=$(grep -n '^plugins=(.*)$' ~/.zshrc | cut -d':' -f1)
    if echo "$plugin" | grep -wq "\b$new_plugin\b"; then
  	    echo "plugin $new_plugin already exist"
    else
  	    $SED_CMD ""$line"s/\(plugins=(.*\))/\1 $new_plugin)/" ~/.zshrc
	    echo "insert $new_plugin successfully"
    fi
}

clone_plugin() {
    local REPO_URL=$1
    local DEST_DIR=$2
    if [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR")" ]; then
        rm -rf "$DEST_DIR"
    fi
    git clone --depth=1 "$REPO_URL" "$DEST_DIR"
}

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-autosuggestions
add_zsh_plugin "zsh-autosuggestions"

# zsh-syntax-highlighting
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
add_zsh_plugin "zsh-syntax-highlighting"

# Add other plugins
add_zsh_plugin "z"
add_zsh_plugin "extract"
