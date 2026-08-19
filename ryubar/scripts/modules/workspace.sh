#!/usr/bin/env bash

# =====================================
# RyuBar KDE Workspace Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/dbus.sh"
source "$RYUBAR_DIR/scripts/helpers/colors.sh"

if [[ -z "${QDBUS:-}" ]]; then
    printf '\n'
    exit 0
fi

CURRENT="$(
    "$QDBUS" org.kde.KWin /KWin currentDesktop 2>/dev/null || true
)"

TOTAL="$(
    awk -F= '
        /^\[Desktops\]$/ { in_section=1; next }
        /^\[/ { in_section=0 }
        in_section && /^Number=/ { print $2; exit }
    ' "$HOME/.config/kwinrc"
)"

if [[ ! "$CURRENT" =~ ^[0-9]+$ || ! "$TOTAL" =~ ^[0-9]+$ ]]; then
    printf '\n'
    exit 0
fi

if (( TOTAL < 1 || CURRENT < 1 || CURRENT > TOTAL )); then
    printf '\n'
    exit 0
fi

ACCENT="$(get_color accent '#00D9FF')"
FOREGROUND="$(get_color foreground '#ECECEC')"

ACTIVE="󰮯"
INACTIVE="󰊠"

OUTPUT=""

for ((i = 1; i <= TOTAL; i++)); do

    OUTPUT+="%{A1:$RYUBAR_DIR/scripts/modules/workspace-action.sh $i:}"

    if (( i == CURRENT )); then
        OUTPUT+="%{F${ACCENT}}${ACTIVE}%{F-}"
    else
        OUTPUT+="%{F${FOREGROUND}}${INACTIVE}%{F-}"
    fi

    OUTPUT+="%{A}"

    if (( i != TOTAL )); then
        OUTPUT+=" "
    fi

done

printf '%s\n' "$OUTPUT"
