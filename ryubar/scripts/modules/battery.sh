#!/usr/bin/env bash

# =====================================
# RyuBar Battery Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

BATTERY_PATH=""

for battery in /sys/class/power_supply/BAT*; do
    if [[ -d "$battery" ]]; then
        BATTERY_PATH="$battery"
        break
    fi
done

if [[ -z "$BATTERY_PATH" ]]; then
    echo ""
    exit 0
fi

CAPACITY="$(cat "$BATTERY_PATH/capacity" 2>/dev/null || echo 0)"
STATUS="$(cat "$BATTERY_PATH/status" 2>/dev/null || echo Unknown)"

case "$STATUS" in
    Charging)
        ICON="󰂄"
        COLOR="${GREEN:-#a6e3a1}"
        ;;

    Full)
        ICON="󰁹"
        COLOR="${GREEN:-#a6e3a1}"
        ;;

    *)
        if (( CAPACITY >= 80 )); then
            ICON="󰁹"
            COLOR="${GREEN:-#a6e3a1}"
        elif (( CAPACITY >= 60 )); then
            ICON="󰂀"
            COLOR="${GREEN:-#a6e3a1}"
        elif (( CAPACITY >= 40 )); then
            ICON="󰁾"
            COLOR="${YELLOW:-#f9e2af}"
        elif (( CAPACITY >= 20 )); then
            ICON="󰁼"
            COLOR="${ORANGE:-#fab387}"
        else
            ICON="󰁺"
            COLOR="${RED:-#f38ba8}"
        fi
        ;;
esac

printf "%%{F%s}%s %s%%%%{F-}\n" \
    "$COLOR" \
    "$ICON" \
    "$CAPACITY"
