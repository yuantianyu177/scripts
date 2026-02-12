#!/usr/bin/env bash

set -euo pipefail

SSH_DIR="$HOME/.ssh"

# ---------- Utility functions ----------
clear_screen() {
  clear
}

is_valid_name() {
  [[ "$1" =~ ^[a-zA-Z0-9._-]+$ ]]
}

# ---------- Step 1: Select algorithm ----------
while true; do
  clear_screen
  echo "=============================="
  echo " SSH Public Key Generator"
  echo "=============================="
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
      echo "Invalid option, please try again..."
      sleep 1
      ;;
  esac
done

# ---------- Step 2: Enter username ----------
while true; do
  clear_screen
  echo "=============================="
  echo " SSH Public Key Generator"
  echo "=============================="
  echo
  read -p "Enter username: " USERNAME

  if [ -z "$USERNAME" ]; then
    echo "Username cannot be empty"
    sleep 1
    continue
  fi

  if ! is_valid_name "$USERNAME"; then
    echo "Username contains invalid characters"
    sleep 1
    continue
  fi

  break
done

# ---------- Step 3: Enter hostname ----------
while true; do
  clear_screen
  echo "=============================="
  echo " SSH Public Key Generator"
  echo "=============================="
  echo
  read -p "Enter hostname: " HOSTNAME

  if [ -z "$HOSTNAME" ]; then
    echo "Hostname cannot be empty"
    sleep 1
    continue
  fi

  if ! is_valid_name "$HOSTNAME"; then
    echo "Hostname contains invalid characters"
    sleep 1
    continue
  fi

  break
done

COMMENT="${USERNAME}@${HOSTNAME}"
KEY_FILE="$SSH_DIR/$KEY_NAME"

# ---------- Step 4: Generate ----------
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
echo "SSH public key generated successfully!"
echo "Public key path: ${KEY_FILE}.pub"
echo "Public key content:"
echo "--------------------------------"
cat "${KEY_FILE}.pub"
echo "--------------------------------"
