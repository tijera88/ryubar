#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/config.sh"

FILE_MANAGER="$(get_file_manager)"
LABS="$(get_labs_path)"

if ! command -v "$FILE_MANAGER" >/dev/null 2>&1; then
    echo "ERROR: File manager not found: $FILE_MANAGER" >&2
    exit 1
fi

case "${1:-}" in

    left)
        "$FILE_MANAGER" "$HOME" >/dev/null 2>&1 &
        ;;

    right)
    if [[ -d "$LABS" ]]; then
        "$FILE_MANAGER" "$LABS" >/dev/null 2>&1 &
    else
        "$FILE_MANAGER" "$HOME" >/dev/null 2>&1 &
    fi
    ;;

    *)
        echo "Usage: $0 {left|right}" >&2
        exit 1
        ;;

esac
