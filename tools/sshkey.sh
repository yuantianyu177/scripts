#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/log.sh"

SSH_DIR="$HOME/.ssh"

clear_screen() {
  clear
}

is_valid_name() {
  [[ "$1" =~ ^[a-zA-Z0-9._-]+$ ]]
}

print_header() {
  echo "=============================="
  echo " SSH Public Key Generator"
  echo "=============================="
}

while true; do
  clear_screen
  print_header
  echo "Select encryption algorithm:"
  echo "1) ed25519"
  echo "2) rsa 4096"
  echo
  read -p "Enter option [1-2] (default 1): " ALG_CHOICE

  case "$ALG_CHOICE" in
    2)
      KEY_TYPE="rsa"
      KEY_BITS=4096
      KEY_NAME="id_rsa"
      break
      ;;
    ""|1)
      KEY_TYPE="ed25519"
      KEY_BITS=""
      KEY_NAME="id_ed25519"
      break
      ;;
    *)
      log_warn "Invalid option, please try again..."
      sleep 1
      ;;
  esac
done

while true; do
  clear_screen
  print_header
  echo
  read -p "Enter username: " USERNAME

  if [ -z "$USERNAME" ]; then
    log_error "Username cannot be empty"
    sleep 1
    continue
  fi

  if ! is_valid_name "$USERNAME"; then
    log_error "Username contains invalid characters"
    sleep 1
    continue
  fi

  break
done

while true; do
  clear_screen
  print_header
  echo
  read -p "Enter hostname: " HOSTNAME

  if [ -z "$HOSTNAME" ]; then
    log_error "Hostname cannot be empty"
    sleep 1
    continue
  fi

  if ! is_valid_name "$HOSTNAME"; then
    log_error "Hostname contains invalid characters"
    sleep 1
    continue
  fi

  break
done

COMMENT="${USERNAME}@${HOSTNAME}"
KEY_FILE="$SSH_DIR/$KEY_NAME"

clear_screen
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo
if [ "$KEY_TYPE" = "rsa" ]; then
  ssh-keygen -t rsa -b "$KEY_BITS" -f "$KEY_FILE" -C "$COMMENT"
else
  ssh-keygen -t ed25519 -f "$KEY_FILE" -C "$COMMENT"
fi

chmod 600 "$KEY_FILE"
chmod 644 "${KEY_FILE}.pub"

clear_screen
print_box "Success" "SSH public key generated!
Public key path: ${KEY_FILE}.pub"
echo "Public key content:"
echo "--------------------------------"
cat "${KEY_FILE}.pub"
echo "--------------------------------"
