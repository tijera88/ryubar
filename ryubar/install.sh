#!/usr/bin/env bash

set -euo pipefail

# =====================================
# RyuBar Installer
# =====================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

RYUBAR_DIR="$HOME/.config/ryubar"
CONFIG_DIR="$HOME/.config"

POLYBAR_LINK="$CONFIG_DIR/polybar"
BACKUP_DIR="$CONFIG_DIR/polybar.backup"

echo "================================="
echo "        RyuBar Installer"
echo "================================="
echo

# -------------------------------------
# Check environment
# -------------------------------------

echo "[1/6] Checking environment..."

if [[ ! -d "$SCRIPT_DIR/polybar" ]]; then
    echo "ERROR: polybar directory not found:"
    echo "  $SCRIPT_DIR/polybar"
    exit 1
fi

if [[ ! -d "$SCRIPT_DIR/scripts" ]]; then
    echo "ERROR: scripts directory not found:"
    echo "  $SCRIPT_DIR/scripts"
    exit 1
fi
missing_dependencies=()

for dependency in rsync polybar kdialog; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        missing_dependencies+=("$dependency")
    fi
done

if ! command -v qdbus6 >/dev/null 2>&1 && \
   ! command -v qdbus >/dev/null 2>&1; then
    missing_dependencies+=("qdbus/qdbus6")
fi

if (( ${#missing_dependencies[@]} > 0 )); then
    echo
    echo "ERROR: Missing required dependencies:"
    echo

    for dependency in "${missing_dependencies[@]}"; do
        echo "  - $dependency"
    done

    echo
    echo "Install the missing packages and run the installer again."
    exit 1
fi

echo "OK"

# -------------------------------------
# Create directories
# -------------------------------------

echo
echo "[2/6] Creating directories..."

mkdir -p "$CONFIG_DIR"
mkdir -p "$RYUBAR_DIR"
mkdir -p "$RYUBAR_DIR/logs"
mkdir -p "$RYUBAR_DIR/cache"

echo "OK"

# -------------------------------------
# Stop running Polybar
# -------------------------------------

echo
echo "[3/6] Stopping existing Polybar..."

if command -v polybar >/dev/null 2>&1; then
    pkill -x polybar 2>/dev/null || true
fi

echo "OK"

# -------------------------------------
# Validate Polybar backup state
# -------------------------------------

if [[ -e "$POLYBAR_LINK" && ! -L "$POLYBAR_LINK" && -e "$BACKUP_DIR" ]]; then
    echo
    echo "ERROR: An existing Polybar configuration was found:"
    echo "  $POLYBAR_LINK"
    echo
    echo "A backup already exists:"
    echo "  $BACKUP_DIR"
    echo
    echo "Installation aborted before modifying RyuBar files."
    exit 1
fi

# -------------------------------------
# Install RyuBar files
# -------------------------------------

echo
echo "[4/6] Installing RyuBar files..."

rsync -a \
    --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='logs/' \
    --exclude='cache/' \
    --exclude='user.conf' \
    "$SCRIPT_DIR/" \
    "$RYUBAR_DIR/"
    
# Preserve existing user configuration.
# Create it from the repository only on a fresh installation.
if [[ ! -f "$RYUBAR_DIR/user.conf" && -f "$SCRIPT_DIR/user.conf" ]]; then
    cp "$SCRIPT_DIR/user.conf" "$RYUBAR_DIR/user.conf"
fi

# Recreate runtime directories after rsync
mkdir -p "$RYUBAR_DIR/logs"
mkdir -p "$RYUBAR_DIR/cache"

# Ensure shell scripts are executable
find "$RYUBAR_DIR" -type f -name '*.sh' -exec chmod +x {} +

echo "OK"

# -------------------------------------
# Configure Polybar
# -------------------------------------

echo
echo "[5/6] Configuring Polybar..."

EXPECTED_TARGET="$(readlink -f "$RYUBAR_DIR/polybar" 2>/dev/null || true)"

# Existing symbolic link
if [[ -L "$POLYBAR_LINK" ]]; then
    CURRENT_TARGET="$(readlink -f "$POLYBAR_LINK" 2>/dev/null || true)"

    if [[ "$CURRENT_TARGET" == "$EXPECTED_TARGET" ]]; then
        echo "Polybar symlink already points to RyuBar."
    else
        echo
        echo "ERROR: Existing Polybar symlink points elsewhere:"
        echo "  $CURRENT_TARGET"
        echo
        echo "Expected:"
        echo "  $EXPECTED_TARGET"
        echo
        echo "Installation aborted to avoid overwriting another setup."
        exit 1
    fi

# Existing regular Polybar configuration
elif [[ -e "$POLYBAR_LINK" ]]; then

    mv "$POLYBAR_LINK" "$BACKUP_DIR"

    echo "Previous Polybar configuration backed up to:"
    echo "  $BACKUP_DIR"

    ln -s "$RYUBAR_DIR/polybar" "$POLYBAR_LINK"

# No previous Polybar configuration
else
    ln -s "$RYUBAR_DIR/polybar" "$POLYBAR_LINK"
fi

echo "OK"

# -------------------------------------
# Validate installation
# -------------------------------------

echo
echo "[6/6] Validating installation..."

ERRORS=0

if [[ ! -d "$RYUBAR_DIR" ]]; then
    echo "ERROR: RyuBar directory was not created."
    ERRORS=$((ERRORS + 1))
fi

if [[ ! -f "$RYUBAR_DIR/polybar/config.ini" ]]; then
    echo "ERROR: Polybar config was not installed."
    ERRORS=$((ERRORS + 1))
fi

if [[ ! -d "$RYUBAR_DIR/scripts" ]]; then
    echo "ERROR: Scripts directory was not installed."
    ERRORS=$((ERRORS + 1))
fi

if [[ ! -d "$RYUBAR_DIR/logs" ]]; then
    echo "ERROR: Logs directory was not created."
    ERRORS=$((ERRORS + 1))
fi

if [[ ! -L "$POLYBAR_LINK" ]]; then
    echo "ERROR: Polybar symlink was not created."
    ERRORS=$((ERRORS + 1))
fi

if (( ERRORS > 0 )); then
    echo
    echo "Installation failed with $ERRORS error(s)."
    exit 1
fi

echo "OK"

echo
echo "Starting RyuBar..."

if [[ ! -x "$RYUBAR_DIR/polybar/launch.sh" ]]; then
    echo
    echo "ERROR: RyuBar launcher is not executable:"
    echo "  $RYUBAR_DIR/polybar/launch.sh"
    exit 1
fi

if ! "$RYUBAR_DIR/polybar/launch.sh"; then
    echo
    echo "ERROR: RyuBar was installed, but Polybar failed to start."
    echo
    echo "Try running:"
    echo "  $RYUBAR_DIR/polybar/launch.sh"
    echo
    echo "to see the startup error."
    exit 1
fi

echo
echo "================================="
echo "    RyuBar installed successfully!"
echo "================================="
echo
echo "Installation:"
echo "  $RYUBAR_DIR"
echo
echo "Polybar:"
echo "  $POLYBAR_LINK -> $RYUBAR_DIR/polybar"
echo
echo "Logs:"
echo "  $RYUBAR_DIR/logs/ryubar.log"
echo

exit 0