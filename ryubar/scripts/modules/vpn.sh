#!/usr/bin/env bash

# =====================================
# RyuBar HTB VPN Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/network.sh"
source "$RYUBAR_DIR/scripts/helpers/colors.sh"

main() {
    local interface
    local ip
    local accent

    interface="$(get_vpn_interface || true)"

    if [[ -z "$interface" ]]; then
        printf '\n'
        return 0
    fi

    ip="$(get_vpn_ip "$interface" || true)"

    if [[ -z "$ip" ]]; then
        printf '\n'
        return 0
    fi

    accent="$(get_color accent '#00D9FF')"

    if command -v xdg-open >/dev/null 2>&1; then
        printf '%%{F%s}󰖂 %s%%{F-}' "$accent" "$ip"
        printf '%%{A}\n'
    else
        printf '%%{F%s}󰖂 %s%%{F-}\n' "$accent" "$ip"
    fi
}

main
