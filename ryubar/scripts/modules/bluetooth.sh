#!/usr/bin/env bash

# =====================================
# RyuBar Bluetooth Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

if ! command -v bluetoothctl >/dev/null 2>&1; then
    printf '\n'
    exit 0
fi

GRAY="$(get_color gray '#6C7086')"
ACCENT="$(get_color accent '#00D9FF')"
SUCCESS="$(get_color success '#50FA7B')"

POWERED="$(
    bluetoothctl show 2>/dev/null |
        awk '/Powered:/ {
            print $2
            exit
        }' || true
)"

if [[ "$POWERED" != "yes" ]]; then
    printf '%%{F%s}󰂲%%{F-}\n' "$GRAY"
    exit 0
fi

CONNECTED="$(
    bluetoothctl devices Connected 2>/dev/null |
        wc -l || true
)"

if [[ ! "$CONNECTED" =~ ^[0-9]+$ ]]; then
    CONNECTED=0
fi

if (( CONNECTED > 0 )); then
    printf '%%{F%s}󰂱 %s%%{F-}\n' "$SUCCESS" "$CONNECTED"
else
    printf '%%{F%s}󰂯%%{F-}\n' "$ACCENT"
fi
