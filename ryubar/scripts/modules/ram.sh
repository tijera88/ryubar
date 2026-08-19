#!/usr/bin/env bash

# =====================================
# RyuBar RAM Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

read -r TOTAL USED < <(
    free -b 2>/dev/null |
        awk '/^Mem:/ {
            print $2, $3
        }'
)

if [[ -z "${TOTAL:-}" || ! "$TOTAL" =~ ^[0-9]+$ || "$TOTAL" -eq 0 ]]; then
    printf '\n'
    exit 0
fi

if [[ -z "${USED:-}" || ! "$USED" =~ ^[0-9]+$ ]]; then
    printf '\n'
    exit 0
fi

RAM=$(( USED * 100 / TOTAL ))

if (( RAM >= 90 )); then
    COLOR="$(get_color danger '#FF5555')"
elif (( RAM >= 70 )); then
    COLOR="$(get_color warning '#FFD166')"
else
    COLOR="$(get_color success '#50FA7B')"
fi

printf '%%{F%s}󰍛 %s%%%%{F-}\n' "$COLOR" "$RAM"
