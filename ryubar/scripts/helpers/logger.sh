#!/usr/bin/env bash

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

LOG_DIR="$RYUBAR_DIR/logs"
LOGFILE="$LOG_DIR/ryubar.log"

mkdir -p "$LOG_DIR"

log() {
    local msg="${1:-}"

    printf '%s | %s\n' \
        "$(date '+%F %T')" \
        "$msg" >> "$LOGFILE"
}
