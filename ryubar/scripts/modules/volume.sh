#!/usr/bin/env bash

# =====================================
# RyuBar Volume Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

if ! command -v wpctl >/dev/null 2>&1; then
    printf '\n'
    exit 0
fi

INFO="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"

if [[ -z "$INFO" ]]; then
    printf '\n'
    exit 0
fi

VOLUME="$(
    awk '{printf "%.0f", $2 * 100}' <<< "$INFO"
)"

if [[ ! "$VOLUME" =~ ^[0-9]+$ ]]; then
    printf '\n'
    exit 0
fi

ACCENT="$(get_color accent '#00D9FF')"
DANGER="$(get_color danger '#FF5555')"

if [[ "$INFO" == *"[MUTED]"* ]]; then
    printf '%%{F%s}󰖁 muted%%{F-}\n' "$DANGER"
    exit 0
fi

if (( VOLUME >= 70 )); then
    ICON="󰕾"
elif (( VOLUME >= 30 )); then
    ICON="󰖀"
else
    ICON="󰕿"
fi

printf '%%{F%s}%s %s%%%%{F-}\n' "$ACCENT" "$ICON" "$VOLUME"
