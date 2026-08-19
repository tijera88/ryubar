#!/usr/bin/env bash

set -euo pipefail

# =====================================
# RyuBar Updater
# =====================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RYUBAR_DIR="$HOME/.config/ryubar"

echo "================================="
echo "         RyuBar Updater"
echo "================================="
echo

# -------------------------------------
# Check installation
# -------------------------------------

if [[ ! -d "$RYUBAR_DIR" ]]; then
    echo "ERROR: RyuBar is not installed."
    echo
    echo "Run ./install.sh first."
    exit 1
fi

# -------------------------------------
# Check dependencies
# -------------------------------------

if ! command -v rsync >/dev/null 2>&1; then
    echo "ERROR: rsync is required."
    echo
    echo "Install it with:"
    echo "  sudo apt install rsync"
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is required."
    exit 1
fi

# -------------------------------------
# Check Git repository
# -------------------------------------

if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    echo "ERROR: This script must be executed from the RyuBar Git repository."
    echo
    echo "Expected:"
    echo "  $SCRIPT_DIR/.git"
    exit 1
fi

echo "[1/4] Updating Git repository..."

cd "$SCRIPT_DIR"

git pull --ff-only

echo "OK"

# -------------------------------------
# Stop Polybar
# -------------------------------------

echo
echo "[2/4] Stopping Polybar..."

if command -v polybar >/dev/null 2>&1; then
    pkill -x polybar 2>/dev/null || true
fi

echo "OK"

# -------------------------------------
# Synchronize files
# -------------------------------------

echo
echo "[3/4] Updating installation..."

mkdir -p "$RYUBAR_DIR"

rsync -a \
    --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='logs/' \
    --exclude='cache/' \
    --exclude='user.conf' \
    "$SCRIPT_DIR/" \
    "$RYUBAR_DIR/"

# Preserve or restore user configuration
if [[ ! -f "$RYUBAR_DIR/user.conf" && -f "$SCRIPT_DIR/user.conf" ]]; then
    cp "$SCRIPT_DIR/user.conf" "$RYUBAR_DIR/user.conf"
fi

# Ensure shell scripts are executable
find "$RYUBAR_DIR" -type f -name '*.sh' -exec chmod +x {} +

mkdir -p "$RYUBAR_DIR/logs"
mkdir -p "$RYUBAR_DIR/cache"

echo "OK"

# -------------------------------------
# Validate
# -------------------------------------

echo
echo "[4/4] Validating update..."

if [[ ! -f "$RYUBAR_DIR/polybar/config.ini" ]]; then
    echo "ERROR: Polybar configuration is missing."
    exit 1
fi

echo "OK"

echo
echo "================================="
echo "       RyuBar updated!"
echo "================================="
echo
echo "Installed version:"
git rev-parse --short HEAD
echo
echo "Start RyuBar with:"
echo "  $RYUBAR_DIR/polybar/launch.sh"
echo