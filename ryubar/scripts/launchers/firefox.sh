#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/config.sh"

BROWSER="$(get_browser)"

if ! command -v "$BROWSER" >/dev/null 2>&1; then
    echo "ERROR: Browser not found: $BROWSER" >&2
    exit 1
fi

case "${1:-}" in

    left)
        "$BROWSER" >/dev/null 2>&1 &
        ;;

    right)
        "$BROWSER" --new-window >/dev/null 2>&1 &
        ;;

    *)
        echo "Usage: $0 {left|right}" >&2
        exit 1
        ;;

esac
