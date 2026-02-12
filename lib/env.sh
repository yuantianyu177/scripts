[[ -n "${__ENV_SH__:-}" ]] && return
__ENV_SH__=1

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_pkg() {
  local pkg=$1
  if [ -z "$pkg" ]; then
    echo "Please provide a package name"
    return 1
  fi

  # Detect distribution
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
        echo "Unsupported OS: $ID"
        return 1
        ;;
    esac
  else
    echo "Unable to detect OS type"
    return 1
  fi
}

get_login_shell_rc_file() {
  local shell_name rc_file

  shell_name=$(basename "$SHELL")

  case "$shell_name" in
    bash)
      rc_file="$HOME/.bashrc"
      ;;
    zsh)
      rc_file="$HOME/.zshrc"
      ;;
    ksh)
      rc_file="$HOME/.kshrc"
      ;;
    fish)
      rc_file="$HOME/.config/fish/config.fish"
      ;;
    sh|dash)
      rc_file="$HOME/.profile"
      ;;
    *)
      rc_file="$HOME/.profile"
      ;;
  esac

  echo "$rc_file"
}
