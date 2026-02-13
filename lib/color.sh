# lib/color.sh

[[ -n "${__COLOR_SH__:-}" ]] && return
__COLOR_SH__=1

COLOR_RESET="\033[0m"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BOLD="\033[1m"
DIM="\033[2m"
