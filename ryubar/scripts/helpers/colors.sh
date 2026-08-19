#!/usr/bin/env bash

# =====================================
# RyuBar Color Helper
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

COLORS_FILE="$RYUBAR_DIR/polybar/colors.ini"

get_color() {
    local name="${1:-}"
    local fallback="${2:-#FFFFFF}"
    local value

    if [[ -z "$name" ]]; then
        printf '%s\n' "$fallback"
        return 0
    fi

    if [[ ! -f "$COLORS_FILE" ]]; then
        printf '%s\n' "$fallback"
        return 0
    fi

    value="$(
        awk -F= -v key="$name" '
            /^[[:space:]]*#/ {
                next
            }

            /^[[:space:]]*$/ {
                next
            }

            {
                current=$1
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)

                if (current == key) {
                    value=$2
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                    print value
                    exit
                }
            }
        ' "$COLORS_FILE"
    )"

    if [[ -n "$value" ]]; then
        printf '%s\n' "$value"
    else
        printf '%s\n' "$fallback"
    fi
}
