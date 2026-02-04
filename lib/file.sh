[[ -n "${__FILE_SH__:-}" ]] && return
__FILE_SH__=1

append_if_not_exists() {
  local file="$2"
  local content="$1"

  [[ -z "$content" ]] && return
  [[ ! -f "$file" ]] && return
  # 判断文件中是否已经包含完全一样的内容
  # 用 grep -F -x -q 支持多行匹配需特殊处理
  if grep -Fxq "$content" "$file"; then
    return
  fi

  echo -e "$content" >> "$file"
}
