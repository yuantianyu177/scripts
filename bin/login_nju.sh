#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_FILE="$ROOT_DIR/.data"

username=""
password=""

# 尝试读取 .data 文件
if [[ -f "$DATA_FILE" ]]; then
  source "$DATA_FILE" || true
fi

# 如果已存在用户名和密码
if [[ -n "${username:-}" && -n "${password:-}" ]]; then
  read -p "检测到已保存用户 $username，是否使用该用户登录？(y/n)： " use_saved
  if [[ "$use_saved" != "y" ]]; then
    username=""
    password=""
  fi
fi

# 如果没有可用的用户名或密码，要求用户输入
if [[ -z "${username:-}" || -z "${password:-}" ]]; then
  read -p "请输入学号：" username
  read -p "请输入密码：" password

  read -p "是否保存学号和密码(y/n)：" is_save
  if [[ "$is_save" == "y" ]]; then
    cat > "$DATA_FILE" <<EOF
username="$username"
password="$password"
EOF
  fi
fi

# 登录请求
curl -s "http://p2.nju.edu.cn/api/portal/v1/login" \
  -d "{\"domain\":\"default\",\"username\":\"$username\",\"password\":\"$password\"}"
