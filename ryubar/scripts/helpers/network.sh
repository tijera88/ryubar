#!/usr/bin/env bash

# =====================================
# RyuBar Network Helper
# =====================================

set -euo pipefail

get_vpn_interface() {
    ip -o -4 addr show 2>/dev/null |
        awk '
            $2 ~ /^(tun|wg)/ &&
            $4 ~ /^10\./ {
                print $2
                exit
            }
        '
}

get_vpn_ip() {
    local interface="${1:-}"

    if [[ -z "$interface" ]]; then
        return 0
    fi

    ip -o -4 addr show dev "$interface" 2>/dev/null |
        awk '$3 == "inet" {
            split($4, address, "/")
            print address[1]
            exit
        }'
}

vpn_active() {
    [[ -n "$(get_vpn_interface || true)" ]]
}