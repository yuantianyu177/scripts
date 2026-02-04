#!/usr/bin/env bash
set -euo pipefail
                
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"
source "$ROOT_DIR/lib/env.sh"
source "$ROOT_DIR/lib/file.sh"

OS_TYPE="$(uname -s)"
ARCH_TYPE="$(uname -m)"

if [[ "$OS_TYPE" != "Darwin" && "$OS_TYPE" != "Linux" ]]; then
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

if [[ "$ARCH_TYPE" != "x86_64" && "$ARCH_TYPE" != "arm64" && "$ARCH_TYPE" != "aarch64" ]]; then
    echo "Unsupported architecture: $ARCH_TYPE"
    exit 1
fi

if [[ "$OS_TYPE" == "Linux" ]]; then
    OS="Linux"
else
    OS="MacOSX"
fi

BASE_URL="https://mirrors.nju.edu.cn/anaconda/miniconda/"
INSTALLER="Miniconda3-latest-$OS-$ARCH_TYPE.sh"

# 下载并安装 Miniconda
wget "${BASE_URL}${INSTALLER}" -O conda.sh
bash conda.sh -b -u -p "$HOME/.local/share/miniconda3" && rm conda.sh

# 更新 shell 配置文件
RC_FILE=$(get_login_shell_rc_file)
content='# miniconda3
export PATH="$HOME/.local/share/miniconda3/bin:$PATH"
source "$HOME/.local/share/miniconda3/bin/activate"'
append_if_not_exists "$content" "$RC_FILE"

# 配置 Conda 镜像源
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

message="安装路径：$HOME/.local/share/miniconda3
已更新"$RC_FILE"
已更新镜像源$HOME/.condarc"
print 0 "$message"
