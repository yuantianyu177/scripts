# lib/log.sh

[[ -n "${__LOG_SH__:-}" ]] && return
__LOG_SH__=1

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/color.sh"

strwidth() {
  local s="$1"
  local w=0
  local i c b
  for ((i=0; i<${#s}; i++)); do
    c="${s:$i:1}"
    printf -v b '%d' "'$c" 2>/dev/null || b=0
    if (( b >= 128 )); then
      ((w+=2))
    else
      ((w+=1))
    fi
  done
  echo "$w"
}

log_info() {
  echo -e "${BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
  echo -e "${GREEN}[OK]${COLOR_RESET} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${COLOR_RESET} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${COLOR_RESET} $*" >&2
}

log_step() {
  echo -e "${CYAN}➜ $*${COLOR_RESET}"
}

print_box() {
  local title="$1"
  shift
  
  # Build lines array - handle both multi-arg and embedded newlines
  local lines=()
  local arg line
  for arg in "$@"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      lines+=("$line")
    done <<< "$arg"
  done
  
  local max_width=0
  for line in "${lines[@]}"; do
    local w
    w=$(strwidth "$line")
    (( w > max_width )) && max_width=$w
  done
  
  local title_w
  title_w=$(strwidth "$title")
  (( title_w > max_width )) && max_width=$title_w
  (( max_width < 30 )) && max_width=30
  
  local total_inner=$((max_width + 2))
  local border=""
  local j
  for ((j=0; j<total_inner; j++)); do
    border+="─"
  done
  
  local title_pad=$((max_width - title_w))
  
  echo -e "${CYAN}┌${border}┐${COLOR_RESET}"
  printf "${CYAN}│ %s%*s │${COLOR_RESET}\n" "$title" "$title_pad" ""
  echo -e "${CYAN}├${border}┤${COLOR_RESET}"
  
  for line in "${lines[@]}"; do
    local line_w
    line_w=$(strwidth "$line")
    local line_pad=$((max_width - line_w))
    printf "${CYAN}│ %s%*s │${COLOR_RESET}\n" "$line" "$line_pad" ""
  done
  
  echo -e "${CYAN}└${border}┘${COLOR_RESET}"
}
