#!/usr/bin/env bash

check_font() {
    local font="${1:-}"
    local matched

    [[ -n "$font" ]] || return 1

    matched="$(fc-match -f '%{family}\n' "$font" 2>/dev/null || true)"

    grep -Fqi "$font" <<< "$matched"
}

FONTS=(
    "Hack Nerd Font"
    "JetBrainsMono Nerd Font"
    "Symbols Nerd Font"
)

for font in "${FONTS[@]}"; do
    if check_font "$font"; then
        echo "$font OK"
    else
        echo "$font missing"
    fi
done