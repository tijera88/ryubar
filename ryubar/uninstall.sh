#!/usr/bin/env bash

set -euo pipefail

# =====================================
# RyuBar Uninstaller
# =====================================

RYUBAR_DIR="$HOME/.config/ryubar"
POLYBAR_LINK="$HOME/.config/polybar"
BACKUP_DIR="$HOME/.config/polybar.backup"

echo "================================="
echo "       RyuBar Uninstaller"
echo "================================="
echo

# -------------------------------------
# Confirmation
# -------------------------------------

if [[ -t 0 ]]; then
    read -r -p "Remove RyuBar installation? [y/N]: " CONFIRM

    case "$CONFIRM" in
        y|Y|yes|YES)
            ;;
        *)
            echo
            echo "Uninstallation cancelled."
            exit 0
            ;;
    esac
fi

# -------------------------------------
# Stop Polybar
# -------------------------------------

echo "[1/4] Stopping Polybar..."

if command -v polybar >/dev/null 2>&1; then
    pkill -x polybar 2>/dev/null || true
fi

echo "OK"

# -------------------------------------
# Remove Polybar symlink
# -------------------------------------

echo
echo "[2/4] Removing Polybar link..."

if [[ -L "$POLYBAR_LINK" ]]; then
    TARGET="$(readlink -f "$POLYBAR_LINK" 2>/dev/null || true)"
    EXPECTED_TARGET="$(readlink -f "$RYUBAR_DIR/polybar" 2>/dev/null || true)"

    if [[ -n "$TARGET" && "$TARGET" == "$EXPECTED_TARGET" ]]; then
        rm -f "$POLYBAR_LINK"

        echo "Removed:"
        echo "  $POLYBAR_LINK"
    else
        echo
        echo "WARNING: $POLYBAR_LINK does not point to RyuBar."
        echo "It will NOT be removed automatically."

        if [[ -n "$TARGET" ]]; then
            echo "Current target:"
            echo "  $TARGET"
        fi
    fi

elif [[ -e "$POLYBAR_LINK" ]]; then
    echo
    echo "WARNING: $POLYBAR_LINK is not a symlink."
    echo "It will NOT be removed automatically."
fi

echo "OK"

# -------------------------------------
# Restore backup
# -------------------------------------

echo
echo "[3/4] Checking Polybar backup..."

if [[ -e "$BACKUP_DIR" ]]; then

    if [[ -e "$POLYBAR_LINK" ]]; then
        echo "WARNING: Cannot restore backup because:"
        echo "  $POLYBAR_LINK"
        echo "still exists."
    else
        mv "$BACKUP_DIR" "$POLYBAR_LINK"

        echo "Previous Polybar configuration restored:"
        echo "  $POLYBAR_LINK"
    fi

else
    echo "No Polybar backup found."
fi

echo "OK"

# -------------------------------------
# Remove RyuBar
# -------------------------------------

echo
echo "[4/4] Removing RyuBar..."

if [[ -d "$RYUBAR_DIR" ]]; then
    rm -rf "$RYUBAR_DIR"
    echo "Removed:"
    echo "  $RYUBAR_DIR"
else
    echo "RyuBar installation not found."
fi

echo "OK"

echo
echo "================================="
echo "      RyuBar removed!"
echo "================================="
echo