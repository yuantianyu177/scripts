[[ -n "${__ENV_SH__:-}" ]] && return
__ENV_SH__=1

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_pkg() {
  local pkg=$1
  if [ -z "$pkg" ]; then
    echo "请提供软件名"
    return 1
  fi

  # 检测发行版
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian)
        sudo apt install -y "$pkg"
        ;;
      fedora)
        sudo dnf install -y "$pkg"
        ;;
      centos|rhel)
        sudo yum install -y "$pkg"
        ;;
      arch)
        sudo pacman -S --noconfirm "$pkg"
        ;;
      *)
        echo "不支持的系统: $ID"
        return 1
        ;;
    esac
  else
    echo "无法检测系统类型"
    return 1
  fi
}

