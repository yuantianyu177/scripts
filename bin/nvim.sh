#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"

echo "检测最新 Neovim Release..."

# 获取 neovim/neovim 最新版本 tag
TAG=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
    | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

echo "最新版本: $TAG"

# 根据体系结构选择 AppImage 文件名
ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]]; then
    FILE="nvim-linux-x86_64.appimage"
elif [[ "$ARCH" == "aarch64" ]]; then
    FILE="nvim-linux-arm64.appimage"
else
    echo "不支持的架构: $ARCH"
    exit 1
fi

echo "计划下载文件: $FILE"

# 匹配 .appimage 文件，排除 .zsync
URL=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
      | grep -oP '"browser_download_url": "\K[^"]+' \
      | grep "$FILE$")

# 如果官方仓库没有，再试备用仓库
if [[ -z "$URL" ]]; then
    echo "neovim/neovim 没有找到 AppImage，尝试 neovim/neovim-releases..."
    URL=$(curl -s "https://api.github.com/repos/neovim/neovim-releases/releases/latest" \
          | grep -oP '"browser_download_url": "\K[^"]+' \
          | grep "$FILE$")
fi

if [[ -z "$URL" ]]; then
    echo "没有获取到 AppImage 下载链接，此 release 尚未发布对应文件。"
    exit 1
fi

echo "下载链接: $URL"

# 下载
TMP=$(mktemp -d)
curl -L "$URL" -o "$TMP/$FILE"

# 安装到 /usr/local/bin/nvim
sudo mv "$TMP/$FILE" /usr/local/bin/nvim
sudo chmod +x /usr/local/bin/nvim
nvim --version | head -n1
rm -rf "$TMP"

message="安装目录：/usr/local/bin/nvim"
print 0 "$message"
