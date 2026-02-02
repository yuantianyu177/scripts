# lib/log.sh

[[ -n "${__LOG_SH__:-}" ]] && return
__LOG_SH__=1

# 依赖 color
source "$(dirname "${BASH_SOURCE[0]}")/color.sh"

# 计算行显示宽度（中文算两格）
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

  # 计算最长行显示宽度
  local max_len=0
  while IFS= read -r line; do
    local w
    w=$(strwidth "$line")
    (( w > max_len )) && max_len=$w
  done <<< "$message"

  # 打印边框
  local border
  border=$(printf '%*s' "$max_len" '' | tr ' ' '=')
  echo -e "${color}${border}${COLOR_RESET}"

  # 打印内容
  while IFS= read -r line; do
    echo -e "${color}${line}${COLOR_RESET}"
  done <<< "$message"

  echo -e "${color}${border}${COLOR_RESET}"
}

