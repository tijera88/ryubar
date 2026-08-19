#!/usr/bin/env bash

# =====================================
# RyuBar Wi-Fi Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

if ! command -v nmcli >/dev/null 2>&1; then
    printf '\n'
    exit 0
    fi
    
    GRAY="$(get_color gray '#6C7086')"
    ACCENT="$(get_color accent '#00D9FF')"
    
    # -------------------------------------
    # Check Wi-Fi radio
    # -------------------------------------
    
    STATE="$(
        LC_ALL=C nmcli -t -f WIFI general 2>/dev/null || true
    )"
    
    if [[ "$STATE" != "enabled" ]]; then
        printf '%%{F%s}󰖪 off%%{F-}\n' "$GRAY"
        exit 0
        fi
        
        # -------------------------------------
        # Find connected Wi-Fi device
        # -------------------------------------
        
        DEVICE="$(
            LC_ALL=C nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null |
            awk -F: '
        $2 == "wifi" && $3 == "connected" {
        print $1
        exit
        }
        '
        )"
        
        if [[ -z "$DEVICE" ]]; then
            printf '%%{F%s}󰖪 disconnected%%{F-}\n' "$GRAY"
            exit 0
            fi
            
            # -------------------------------------
            # Get active network information
            # -------------------------------------
            
            INFO="$(
                LC_ALL=C nmcli -t -f IN-USE,SIGNAL,SSID device wifi list ifname "$DEVICE" 2>/dev/null |
                awk -F: '
            $1 == "*" {
            print $2 "|" $3
            exit
            }
            '
            )"
            
            if [[ -z "$INFO" ]]; then
                printf '%%{F%s}󰖪 connected%%{F-}\n' "$ACCENT"
                exit 0
                fi
                
                SIGNAL="${INFO%%|*}"
                SSID="${INFO#*|}"
                
                # -------------------------------------
                # Validate signal
                # -------------------------------------
                
                if [[ ! "$SIGNAL" =~ ^[0-9]+$ ]]; then
                    printf '%%{F%s}󰖪 connected%%{F-}\n' "$ACCENT"
                    exit 0
                    fi
                    
                    # -------------------------------------
                    # Select signal icon
                    # -------------------------------------
                    
                    if (( SIGNAL >= 70 )); then
                        ICON="󰤨"
                        elif (( SIGNAL >= 40 )); then
                        ICON="󰤥"
                        else
                            ICON="󰤟"
                            fi
                            
                            printf '%%{F%s}%s %s%%%%{F-}\n' "$ACCENT" "$ICON" "$SIGNAL"
