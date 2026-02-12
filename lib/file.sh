[[ -n "${__FILE_SH__:-}" ]] && return
__FILE_SH__=1

append_if_not_exists() {
  local file="$2"
  local content="$1"

  [[ -z "$content" ]] && return
  [[ ! -f "$file" ]] && return
  # Check if the file already contains the exact same content
  if grep -Fxq "$content" "$file"; then
    return
  fi

  echo -e "$content" >> "$file"
}
