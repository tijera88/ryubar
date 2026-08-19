#!/usr/bin/env bash

# =====================================
# RyuBar Workspace Actions
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/dbus.sh"

ACTION="${1:-}"

if [[ -z "${QDBUS:-}" ]]; then
    exit 1
fi

case "$ACTION" in

    next)
        "$QDBUS" org.kde.KWin /KWin nextDesktop
        ;;

    previous)
        "$QDBUS" org.kde.KWin /KWin previousDesktop
        ;;

    [1-9]*)
        "$QDBUS" org.kde.KWin /KWin setCurrentDesktop "$ACTION"
        ;;

    *)
        echo "Usage: $0 {next|previous|DESKTOP}" >&2
        exit 1
        ;;

esac
