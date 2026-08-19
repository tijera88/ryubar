#!/usr/bin/env bash

# =====================================
# RyuBar D-Bus Helper
# =====================================

QDBUS="${QDBUS:-}"

get_qdbus() {
    if [[ -n "$QDBUS" ]]; then
        printf '%s\n' "$QDBUS"
        return 0
    fi

    if command -v qdbus6 >/dev/null 2>&1; then
        printf '%s\n' "qdbus6"
        return 0
    fi

    if command -v qdbus >/dev/null 2>&1; then
        printf '%s\n' "qdbus"
        return 0
    fi

    return 1
}

if ! QDBUS="$(get_qdbus)"; then
    QDBUS=""
fi

export QDBUS
