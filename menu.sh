#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/log.sh"

# Categories: directory name -> display name
# Add new categories here
CATEGORIES=(
  "installers:Software Installers"
  "tools:Utility Tools"
)

# Collect scripts from all category directories
all_scripts=()
all_labels=()
category_ranges=()  # "start:end:name"

idx=0
for entry in "${CATEGORIES[@]}"; do
  dir="${entry%%:*}"
  label="${entry#*:}"
  dir_path="$ROOT_DIR/$dir"

  [[ ! -d "$dir_path" ]] && continue

  scripts=()
  while IFS= read -r f; do
    scripts+=("$f")
  done < <(find "$dir_path" -maxdepth 1 -name '*.sh' -type f | sort)

  [[ ${#scripts[@]} -eq 0 ]] && continue

  start=$((idx + 1))
  for s in "${scripts[@]}"; do
    all_scripts+=("$s")
    all_labels+=("$label")
    (( idx++ )) || true
  done
  end=$idx
  category_ranges+=("$start:$end:$label")
done

if [[ ${#all_scripts[@]} -eq 0 ]]; then
  echo "No scripts found"
  exit 1
fi

# Build lines per category
cat_lines=()
for range in "${category_ranges[@]}"; do
  start="${range%%:*}"
  rest="${range#*:}"
  end="${rest%%:*}"
  label="${rest#*:}"

  lines=()
  lines+=("[$label]")
  for (( i=start; i<=end; i++ )); do
    name=$(basename "${all_scripts[$((i-1))]}" .sh)
    lines+=("$(printf "  %d) %s" "$i" "$name")")
  done
  cat_lines+=("$(printf '%s\n' "${lines[@]}")")
done

# Display in two columns
COL_WIDTH=30
if [[ ${#cat_lines[@]} -ge 2 ]]; then
  col1="${cat_lines[0]}"
  col2="${cat_lines[1]}"
  for (( c=2; c<${#cat_lines[@]}; c++ )); do
    col2+=$'\n'"${cat_lines[$c]}"
  done

  mapfile -t left <<< "$col1"
  mapfile -t right <<< "$col2"
  max=$(( ${#left[@]} > ${#right[@]} ? ${#left[@]} : ${#right[@]} ))

  echo ""
  for (( r=0; r<max; r++ )); do
    printf "%-${COL_WIDTH}s %s\n" "${left[$r]:-}" "${right[$r]:-}"
  done
else
  echo ""
  echo "${cat_lines[0]}"
fi

echo ""
echo "Enter number to run, 'q' to quit"
read -rp "Select: " input

[[ "$input" == "q" ]] && exit 0

if ! [[ "$input" =~ ^[0-9]+$ ]] || (( input < 1 || input > ${#all_scripts[@]} )); then
  echo "Invalid selection" >&2
  exit 1
fi

selected="${all_scripts[$((input - 1))]}"
name=$(basename "$selected" .sh)
echo ""
echo "===== Running: $name ====="
echo ""
bash "$selected"
