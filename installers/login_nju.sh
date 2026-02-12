#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_FILE="$ROOT_DIR/.data"

username=""
password=""

# Try to read .data file
if [[ -f "$DATA_FILE" ]]; then
  source "$DATA_FILE" || true
fi

# If username and password already exist
if [[ -n "${username:-}" && -n "${password:-}" ]]; then
  read -p "Found saved user $username, use this account to login? (y/n): " use_saved
  if [[ "$use_saved" != "y" ]]; then
    username=""
    password=""
  fi
fi

# If no username or password available, prompt for input
if [[ -z "${username:-}" || -z "${password:-}" ]]; then
  read -p "Enter student ID: " username
  read -p "Enter password: " password

  read -p "Save student ID and password? (y/n): " is_save
  if [[ "$is_save" == "y" ]]; then
    cat > "$DATA_FILE" <<EOF
username="$username"
password="$password"
EOF
  fi
fi

# Login request
curl -s "http://p2.nju.edu.cn/api/portal/v1/login" \
  -d "{\"domain\":\"default\",\"username\":\"$username\",\"password\":\"$password\"}"
