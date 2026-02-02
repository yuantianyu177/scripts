#!/usr/bin/env bash

set -euo pipefail

SSH_DIR="$HOME/.ssh"

# ---------- 工具函数 ----------
clear_screen() {
  clear
}

is_valid_name() {
  [[ "$1" =~ ^[a-zA-Z0-9._-]+$ ]]
}

# ---------- Step 1：选择算法 ----------
while true; do
  clear_screen
  echo "=============================="
  echo " 🔐 SSH 公钥生成向导"
  echo "=============================="
  echo "请选择加密算法："
  echo "1) ed25519"
  echo "2) rsa 4096"
  echo
  read -p "输入选项 [1-2]（默认 1）: " ALG_CHOICE

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
      echo "❌ 无效选项，重新输入..."
      sleep 1
      ;;
  esac
done

# ---------- Step 2：输入 username ----------
while true; do
  clear_screen
  echo "=============================="
  echo " 🔐 SSH 公钥生成向导"
  echo "=============================="
  echo
  read -p "请输入 username: " USERNAME

  if [ -z "$USERNAME" ]; then
    echo "❌ username 不能为空"
    sleep 1
    continue
  fi

  if ! is_valid_name "$USERNAME"; then
    echo "❌ username 含有非法字符"
    sleep 1
    continue
  fi

  break
done

# ---------- Step 3：输入 hostname ----------
while true; do
  clear_screen
  echo "=============================="
  echo " 🔐 SSH 公钥生成向导"
  echo "=============================="
  echo
  read -p "请输入 hostname: " HOSTNAME

  if [ -z "$HOSTNAME" ]; then
    echo "❌ hostname 不能为空"
    sleep 1
    continue
  fi

  if ! is_valid_name "$HOSTNAME"; then
    echo "❌ hostname 含有非法字符"
    sleep 1
    continue
  fi

  break
done

COMMENT="${USERNAME}@${HOSTNAME}"
KEY_FILE="$SSH_DIR/$KEY_NAME"

# ---------- Step 4：生成 ----------
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
echo "SSH 公钥生成完成！"
echo "📍 公钥路径：${KEY_FILE}.pub"
echo "📄 公钥内容："
echo "--------------------------------"
cat "${KEY_FILE}.pub"
echo "--------------------------------"

