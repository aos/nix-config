#!/usr/bin/env bash

set -euo pipefail

THEME_DARK="Mono Smoke"
THEME_LIGHT="Mono Lace"

mode="${1:-}"

current_scheme=$(dconf read /org/gnome/desktop/interface/color-scheme 2>/dev/null || true)
current_theme=$(fish -c 'set -q aos_theme; echo $aos_theme' 2>/dev/null || true)

if [[ -z "$mode" ]]; then
  case "$current_scheme" in
    "'prefer-dark'") mode="light" ;;
    "'prefer-light'") mode="dark" ;;
    *)
      if [[ "$current_theme" == "$THEME_DARK" ]]; then
        mode="light"
      elif [[ "$current_theme" == "$THEME_LIGHT" ]]; then
        mode="dark"
      else
        mode="dark"
      fi
      ;;
  esac
fi

case "$mode" in
  dark)
    target_scheme="'prefer-dark'"
    theme_theme="$THEME_DARK"
    ;;
  light)
    target_scheme="'prefer-light'"
    target_theme="$THEME_LIGHT"
    ;;
  *)
    echo "usage: $0 [dark|light]" >&2
    exit 2
    ;;
 esac

if [[ "$current_scheme" != "$target_scheme" ]]; then
  dconf write /org/gnome/desktop/interface/color-scheme "$target_scheme"
fi

if [[ "$current_theme" != "$target_theme" ]]; then
  fish -c "set -U aos_theme \"$target_theme\"; fish_config theme choose \"$target_theme\""
fi
