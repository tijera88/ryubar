#!/usr/bin/env bash

# =====================================
# RyuBar Power Actions
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/dbus.sh"

ACTION="${1:-}"

case "$ACTION" in

    shutdown)
        systemctl poweroff
        ;;

    restart)
        systemctl reboot
        ;;

    suspend)
        systemctl suspend
        ;;

    logout)
        if [[ -z "${QDBUS:-}" ]]; then
            echo "ERROR: qdbus/qdbus6 not found." >&2
            exit 1
        fi

        "$QDBUS" org.kde.Shutdown \
            /Shutdown \
            logout
        ;;

    lock)
        loginctl lock-session
        ;;

    *)
        echo "Usage: $0 {shutdown|restart|suspend|logout|lock}" >&2
        exit 1
        ;;

esac
