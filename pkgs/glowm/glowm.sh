#!/usr/bin/env bash
#
# glowm - Glow with Mermaid support
#
# Pre-processes markdown files to render ```mermaid blocks as ASCII
# before passing to glow for display.

set -euo pipefail

check_deps() {
  local missing=()
  command -v glow >/dev/null 2>&1 || missing+=("glow")
  command -v mermaid-ascii >/dev/null 2>&1 || missing+=("mermaid-ascii")

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Error: Missing dependencies: ${missing[*]}" >&2
    exit 1
  fi
}

process_mermaid() {
  local in_mermaid=false
  local mermaid_content=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^'```mermaid'[[:space:]]*$ ]]; then
      in_mermaid=true
      mermaid_content=""
      continue
    fi

    if $in_mermaid && [[ "$line" =~ ^'```'[[:space:]]*$ ]]; then
      in_mermaid=false
      echo '```'
      printf '%s\n' "$mermaid_content" | mermaid-ascii 2>/dev/null
      echo '```'
      continue
    fi

    if $in_mermaid; then
      [[ -n "$mermaid_content" ]] && mermaid_content+=$'\n'
      mermaid_content+="$line"
      continue
    fi

    printf '%s\n' "$line"
  done
}

main() {
  check_deps

  local glow_args=()
  local input_file=""
  local input_index=-1
  local explicit_stdin=false

  local -a args=("$@")

  for i in "${!args[@]}"; do
    if [[ "${args[i]}" == "-" ]]; then
      explicit_stdin=true
      input_index=$i
    fi
  done

  if ! $explicit_stdin; then
    for ((i=${#args[@]} - 1; i>=0; i--)); do
      if [[ "${args[i]}" != -* ]] && [[ -f "${args[i]}" ]]; then
        input_file="${args[i]}"
        input_index=$i
        break
      fi
    done
  fi

  for i in "${!args[@]}"; do
    if [[ $i -ne $input_index ]]; then
      glow_args+=("${args[i]}")
    fi
  done

  if $explicit_stdin || [[ -z "$input_file" ]]; then
    process_mermaid | glow "${glow_args[@]}" -
  else
    process_mermaid < "$input_file" | glow "${glow_args[@]}" -
  fi
}

main "$@"
