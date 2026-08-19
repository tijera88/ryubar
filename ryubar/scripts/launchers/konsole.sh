#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/config.sh"

TERMINAL="$(get_terminal)"
LABS="$(get_labs_path)"

open_terminal() {
    local directory="${1:-}"

    case "$TERMINAL" in
        konsole)
            if [[ -n "$directory" ]]; then
                "$TERMINAL" --workdir "$directory" >/dev/null 2>&1 &
            else
                "$TERMINAL" >/dev/null 2>&1 &
            fi
            ;;

        kitty)
            if [[ -n "$directory" ]]; then
                "$TERMINAL" --directory "$directory" >/dev/null 2>&1 &
            else
                "$TERMINAL" >/dev/null 2>&1 &
            fi
            ;;

        alacritty)
            if [[ -n "$directory" ]]; then
                "$TERMINAL" --working-directory "$directory" >/dev/null 2>&1 &
            else
                "$TERMINAL" >/dev/null 2>&1 &
            fi
            ;;

        *)
            "$TERMINAL" >/dev/null 2>&1 &
            ;;
    esac
}
case "${1:-left}" in
    left)
        open_terminal
        ;;

    right)
        if [[ -d "$LABS" ]]; then
            open_terminal "$LABS"
        else
            open_terminal "$HOME"
        fi
        ;;

    *)
        open_terminal
        ;;
esac
