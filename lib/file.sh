# lib/file.sh

[[ -n "${__FILE_SH__:-}" ]] && return
__FILE_SH__=1

append_if_not_exists() {
  local file="$1"
  local content="$2"

  [[ -z "$content" ]] && return
  [[ ! -f "$file" ]] && return

  if [[ -s "$file" ]] && grep -Fq "$content" "$file" 2>/dev/null; then
    return
  fi

  echo -e "$content" >> "$file"
}

ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || mkdir -p "$dir"
}

backup_file() {
  local file="$1"
  [[ -f "$file" ]] && cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
}
