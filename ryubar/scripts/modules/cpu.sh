#!/usr/bin/env bash

# =====================================
# RyuBar CPU Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

CPU="$(
    LC_ALL=C top -bn1 2>/dev/null |
        awk -F'[, ]+' '/Cpu\(s\)/ {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^id$/) {
                    idle = $(i-1)
                    printf "%.0f", 100-idle
                    exit
                }
            }
        }'
)"

if [[ ! "$CPU" =~ ^[0-9]+$ ]]; then
    printf '\n'
    exit 0
fi

if (( CPU >= 90 )); then
    COLOR="$(get_color danger '#FF5555')"
elif (( CPU >= 70 )); then
    COLOR="$(get_color warning '#FFD166')"
else
    COLOR="$(get_color accent '#00D9FF')"
fi

printf '%%{F%s} %s%%%%{F-}\n' "$COLOR" "$CPU"
