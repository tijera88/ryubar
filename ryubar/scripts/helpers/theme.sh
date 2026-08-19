#!/usr/bin/env bash

# =====================================
# RyuBar Theme Manager
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

THEMES_DIR="$RYUBAR_DIR/themes"
POLYBAR_DIR="$RYUBAR_DIR/polybar"
COLORS_FILE="$POLYBAR_DIR/colors.ini"

source "$RYUBAR_DIR/scripts/helpers/config.sh"

mkdir -p "$POLYBAR_DIR"

theme="$(get_theme || true)"

if [[ -z "$theme" ]]; then
    theme="default"
fi

THEME_FILE="$THEMES_DIR/${theme}.ini"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "WARNING: Theme '$theme' not found." >&2
    echo "Using default theme." >&2

    theme="default"
    THEME_FILE="$THEMES_DIR/default.ini"
fi

if [[ ! -f "$THEME_FILE" ]]; then
    echo "ERROR: Default theme not found:" >&2
    echo "$THEME_FILE" >&2
    exit 1
fi

get_theme_value() {
    local key="$1"

    awk -F= -v key="$key" '
        /^[[:space:]]*#/ {
            next
        }

        /^[[:space:]]*$/ {
            next
        }

        {
            current=$1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)

            if (current == key) {
                value=$2
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                print value
                exit
            }
        }
    ' "$THEME_FILE"
}

BACKGROUND="$(get_theme_value background)"
FOREGROUND="$(get_theme_value foreground)"
ACCENT="$(get_theme_value accent)"
SUCCESS="$(get_theme_value success)"
WARNING="$(get_theme_value warning)"
DANGER="$(get_theme_value danger)"
GRAY="$(get_theme_value gray)"
RADIUS="$(get_theme_value radius)"
HEIGHT="$(get_theme_value height)"

BACKGROUND="${BACKGROUND:-#11151C}"
FOREGROUND="${FOREGROUND:-#ECECEC}"
ACCENT="${ACCENT:-#00D9FF}"
SUCCESS="${SUCCESS:-#50FA7B}"
WARNING="${WARNING:-#FFD166}"
DANGER="${DANGER:-#FF5555}"
GRAY="${GRAY:-#6C7086}"
RADIUS="${RADIUS:-12}"
HEIGHT="${HEIGHT:-36}"

cat > "$COLORS_FILE" <<EOF
#################################
# RyuBar Generated Theme
# Theme: $theme
#################################

[color]

background = $BACKGROUND
foreground = $FOREGROUND

accent = $ACCENT

success = $SUCCESS
lab = $SUCCESS

warning = $WARNING
danger = $DANGER

gray = $GRAY

transparent = #00000000

[appearance]

radius = $RADIUS
height = $HEIGHT
EOF

echo "RyuBar theme applied: $theme"
