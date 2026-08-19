#!/usr/bin/env bash

# =====================================
# RyuBar State Helper
# =====================================

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

STATE_DIR="$RYUBAR_DIR/cache"
STATE_FILE="$STATE_DIR/lab.state"

get_lab_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        printf '%s\n' "normal"
    fi
}

set_lab_state() {
    local state="${1:-normal}"

    mkdir -p "$STATE_DIR"

    printf '%s\n' "$state" > "$STATE_FILE"
}
