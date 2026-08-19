#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"
TARGET_FILE="$RYUBAR_DIR/state/target"

if [[ -s "$TARGET_FILE" ]]; then
    target="$(head -n 1 "$TARGET_FILE")"
    printf '󰓾 %s\n' "$target"
else
    printf '󰓾 \n'
fi
