#!/usr/bin/env bash

set -euo pipefail

# 引入公共库
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"

WORKDIR=$PWD

# Download clash 
cd /tmp
mkdir -p $HOME/.local/bin
wget "https://kflxc.big-files.make-w0rld-static.club:8000/file/ikuuu-static-release/clash-linux/clash-linux-1.0.1/clash-linux-amd64.gz" -O clash-linux-amd64.gz;
gzip -d clash-linux-amd64.gz
chmod +x clash-linux-amd64
mv clash-linux-amd64 $HOME/.local/bin/clash

# Download config
mkdir -p $HOME/.config/clash && cd $HOME/.config/clash
wget -O config.yaml "https://hjvh8.no-mad-world.club/link/HsHy1jgixpUySi3c?clash=3"

# Config git
git config --global http.proxy 'http://127.0.0.1:7890'
git config --global https.proxy 'https://127.0.0.1:7890'

CONTENT=$(cat <<EOL
# clash
alias clash_start="tmux new-session -d -s clash $HOME/.local/bin/clash -d $HOME/.config/clash"
alias clash_stop='tmux kill-session -t clash'
alias proxy_on='export https_proxy=127.0.0.1:7890 && export http_proxy=127.0.0.1:7890'
alias proxy_off='unset http_proxy https_proxy'
EOL
)

for rc in ~/.bashrc ~/.zshrc; do
    [ -f "$rc" ] || continue

    if ! grep -Fqx "$CONTENT" "$rc"; then
        printf "\n%s\n" "$CONTENT" >> "$rc"
    fi
done

cd $WORKDIR
message="安装路径：$HOME/.local/bin/clash
配置文件路径：$HOME/.config/clash"
print 0 "$message"
