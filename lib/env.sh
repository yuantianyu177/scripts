# lib/env.sh

[[ -n "${__ENV_SH__:-}" ]] && return
__ENV_SH__=1

source "$(dirname "${BASH_SOURCE[0]}")/log.sh"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_sudo() {
  if ! sudo -v 2>/dev/null; then
    log_error "sudo privileges required"
    return 1
  fi
  return 0
}

install_pkg() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    log_error "Please provide a package name"
    return 1
  fi

  if [[ -f /etc/os-release ]]; then
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
        log_error "Unsupported OS: $ID"
        return 1
        ;;
    esac
  else
    log_error "Unable to detect OS type"
    return 1
  fi
}

get_login_shell_rc_file() {
  local shell_name="$1"
  [[ -z "$shell_name" ]] && shell_name=$(basename "$SHELL")

  case "$shell_name" in
    bash) echo "$HOME/.bashrc" ;;
    zsh) echo "$HOME/.zshrc" ;;
    ksh) echo "$HOME/.kshrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *) echo "$HOME/.profile" ;;
  esac
}
