#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"
TARGET_FILE="$RYUBAR_DIR/state/target"

mkdir -p "$(dirname "$TARGET_FILE")"

case "${1:-}" in
    clear)
        : > "$TARGET_FILE"
        ;;
    "")
        echo "Uso: $0 <IP|hostname|clear>" >&2
        exit 1
        ;;
    *)
        printf '%s\n' "$1" > "$TARGET_FILE"
        ;;
esac
