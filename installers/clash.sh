#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
WORKDIR=$PWD

log_info "Downloading clash..."
cd /tmp
mkdir -p "$HOME/.local/bin"
wget "https://kflxc.big-files.make-w0rld-static.club:8000/file/ikuuu-static-release/clash-linux/clash-linux-1.0.1/clash-linux-amd64.gz" -O clash-linux-amd64.gz || {
  log_error "Failed to download clash"
  exit 1
}
gzip -d clash-linux-amd64.gz
chmod +x clash-linux-amd64
mv clash-linux-amd64 "$HOME/.local/bin/clash"

log_info "Enter clash config URL:"
read -p "> " CONFIG_URL
mkdir -p "$HOME/.config/clash" && cd "$HOME/.config/clash"
wget -O config.yaml "$CONFIG_URL" || {
  log_error "Failed to download config"
  exit 1
}

git config --global http.proxy 'http://127.0.0.1:7890'
git config --global https.proxy 'https://127.0.0.1:7890'

CONTENT=$(cat <<EOL
# clash
alias clash_start="tmux new-session -d -s clash $HOME/.local/bin/clash -d $HOME/.config/clash"
alias clash_stop='pkill clash'
alias proxy_on='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias proxy_off='unset http_proxy https_proxy'
EOL
)

for rc in ~/.bashrc ~/.zshrc; do
    [ -f "$rc" ] || continue

    if ! grep -Fqx "$CONTENT" "$rc"; then
        printf "\n%s\n" "$CONTENT" >> "$rc"
    fi
done

log_info "Installing clash-dashboard..."
DIR="$HOME/.config/clash"
rm -rf "$DIR/clash-dashboard"
git clone https://github.com/eorendel/clash-dashboard.git "$DIR/clash-dashboard" || {
  log_warn "Failed to clone dashboard, continuing..."
}
sed -i '/^secret:/d' "$DIR/config.yaml"
sed -i '/^external-ui:/d' "$DIR/config.yaml"
sed -i '/^external-controller:/d' "$DIR/config.yaml"
sed -i "6i external-controller: 127.0.0.1:9090\nsecret: \"yty&123\"\nexternal-ui: $DIR/clash-dashboard" "$DIR/config.yaml"

cd "$WORKDIR"

print_box "Success" "Clash for Linux installed!
Config path: $HOME/.config/clash
Start: clash_start
Stop: clash_stop
Enable proxy: proxy_on
Disable proxy: proxy_off"
