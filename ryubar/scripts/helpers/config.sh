#!/usr/bin/env bash

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

USER_CONFIG="$RYUBAR_DIR/user.conf"

if [[ ! -f "$USER_CONFIG" ]]; then
    echo "ERROR: Configuration file not found:" >&2
    echo "$USER_CONFIG" >&2
    exit 1
fi


get_config() {

    local section="${1:-}"
    local key="${2:-}"
    local value

    [[ -n "$section" ]] || return 1
    [[ -n "$key" ]] || return 1

    value="$(
        awk -F= -v section="$section" -v key="$key" '

            /^\[[^]]+\]$/ {

                current=$0

                gsub(/^\[/, "", current)
                gsub(/\]$/, "", current)

                next
            }

            current == section &&
            $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {

                value=$0

                sub(/^[^=]*=[[:space:]]*/, "", value)

                gsub(/[[:space:]]+$/, "", value)

                print value

                exit
            }

        ' "$USER_CONFIG"
    )"

    value="${value#\"}"
    value="${value%\"}"

    value="${value#\'}"
    value="${value%\'}"

    # Expand home directory.
    value="${value/#\~/$HOME}"

    # Expand environment variables commonly used.
    value="${value//\$\{HOME\}/$HOME}"
    value="${value//\$HOME/$HOME}"

    printf '%s\n' "$value"
}


get_theme() {
    get_config appearance theme
}


get_browser() {
    get_config applications browser
}


get_terminal() {
    get_config applications terminal
}


get_file_manager() {
    get_config applications file_manager
}

get_labs_path() {
    get_config paths htb
}
