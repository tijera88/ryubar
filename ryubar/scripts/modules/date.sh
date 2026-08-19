#!/usr/bin/env bash

# =====================================
# RyuBar Date Module
# =====================================

set -euo pipefail

RYUBAR_DIR="${RYUBAR_DIR:-$HOME/.config/ryubar}"

source "$RYUBAR_DIR/scripts/helpers/colors.sh"

COLOR="$(get_color foreground '#ECECEC')"

printf '%%{F%s}󰥔 %s%%{F-}\n' "$COLOR" "$(date '+%d/%m %H:%M')"