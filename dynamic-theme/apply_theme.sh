#!/usr/bin/env bash
# ~/.config/caelestia/apply_theme.sh

set -euo pipefail
echo "[apply_theme] FIRED at $(date) WALLPAPER_PATH=$WALLPAPER_PATH" >> /tmp/theme_hook.log

WALLPAPER="${1:-${WALLPAPER_PATH:-}}"
SCRIPT="$HOME/.config/caelestia/apply_theme.py"

if [[ -z "$WALLPAPER" ]]; then echo "[apply_theme] No wallpaper path provided." >&2; exit 1; fi
if [[ ! -f "$WALLPAPER" ]]; then echo "[apply_theme] File not found: $WALLPAPER" >&2; exit 1; fi

sleep 1

python3 "$SCRIPT" "$WALLPAPER"

# Tell quickshell to reload the scheme
#caelestia scheme set -n dynamic -m dark -v expressive
env >> /tmp/theme_hook_env.log
