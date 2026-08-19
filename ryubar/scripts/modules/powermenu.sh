#!/usr/bin/env bash

# =====================================
# RyuBar Power Menu
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

if ! command -v kdialog >/dev/null 2>&1; then
    exit 1
fi

CHOICE="$(
    kdialog \
        --menu "RyuBar Power" \
        lock "Lock Session" \
        logout "Logout" \
        suspend "Suspend" \
        reboot "Restart" \
        shutdown "Shutdown"
)" || exit 0

case "$CHOICE" in
    lock)
        "$RYUBAR_DIR/scripts/modules/power.sh" lock
        ;;

    logout)
        "$RYUBAR_DIR/scripts/modules/power.sh" logout
        ;;

    suspend)
        "$RYUBAR_DIR/scripts/modules/power.sh" suspend
        ;;

    reboot)
        "$RYUBAR_DIR/scripts/modules/power.sh" restart
        ;;

    shutdown)
        "$RYUBAR_DIR/scripts/modules/power.sh" shutdown
        ;;
esac