# lib/log.sh

[[ -n "${__LOG_SH__:-}" ]] && return
__LOG_SH__=1

source "$(dirname "${BASH_SOURCE[0]}")/color.sh"

# Calculate display width of a string (CJK characters count as 2)
strwidth() {
  awk -v s="$1" 'BEGIN {
    w=0;
    for(i=1;i<=length(s);i++){
      c=substr(s,i,1);
      if(c ~ /[^\x00-\x7F]/) { w+=2 } else { w+=1 }
    }
    print w
  }'
}


print() {
  local status="$1"
  shift
  local message="$*"

  local color
  if [[ "$status" -eq 0 ]]; then
    color="$GREEN"
  else
    color="$RED"
  fi

  # Find the longest line display width
  local max_len=0
  while IFS= read -r line; do
    local w
    w=$(strwidth "$line")
    (( w > max_len )) && max_len=$w
  done <<< "$message"

  # Print border
  local border
  border=$(printf '%*s' "$max_len" '' | tr ' ' '=')
  echo -e "${color}${border}${COLOR_RESET}"

  # Print content
  while IFS= read -r line; do
    echo -e "${color}${line}${COLOR_RESET}"
  done <<< "$message"

  echo -e "${color}${border}${COLOR_RESET}"
}
