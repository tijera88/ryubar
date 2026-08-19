#!/usr/bin/env bash

# =====================================
# RyuBar KDE Launcher
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/dbus.sh"

case "${1:-left}" in

    left)

    if [[ -z "${QDBUS:-}" ]]; then
        exit 1
    fi

    "$QDBUS" \
        org.kde.plasmashell \
        /PlasmaShell \
        org.kde.PlasmaShell.activateLauncherMenu
    ;;

    right)
        if command -v krunner >/dev/null 2>&1; then
            krunner
        fi
        ;;

    *)
        echo "Usage: $0 {left|right}" >&2
        exit 1
        ;;

esac
