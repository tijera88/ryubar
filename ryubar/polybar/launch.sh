#!/usr/bin/env bash

# =====================================
# RyuBar Launcher
# =====================================

set -euo pipefail

# -------------------------------------
# Paths
# -------------------------------------

RYUBAR_DIR="$HOME/.config/ryubar"
POLYBAR_DIR="$RYUBAR_DIR/polybar"
POLYBAR_LINK="$HOME/.config/polybar"
BACKUP_DIR="$HOME/.config/polybar.backup"

# -------------------------------------
# Verify RyuBar installation
# -------------------------------------

if [[ ! -d "$RYUBAR_DIR" ]]; then
    echo
    echo "ERROR: RyuBar is not installed."
    echo
    echo "Expected directory:"
    echo "  $RYUBAR_DIR"
    echo
    echo "Run the installer first."
    exit 1
fi

if [[ ! -d "$POLYBAR_DIR" ]]; then
    echo
    echo "ERROR: Polybar directory not found."
    echo
    echo "Expected directory:"
    echo "  $POLYBAR_DIR"
    exit 1
fi

mkdir -p "$RYUBAR_DIR/logs"
mkdir -p "$RYUBAR_DIR/cache"

# -------------------------------------
# Logger
# -------------------------------------

LOGGER="$RYUBAR_DIR/scripts/helpers/logger.sh"

if [[ -f "$LOGGER" ]]; then
    # shellcheck disable=SC1090
    source "$LOGGER"
else
    log() {
        printf '[RyuBar] %s\n' "$*"
    }
fi

log "Starting RyuBar"
source "$RYUBAR_DIR/scripts/helpers/dbus.sh"

THEME_MANAGER="$RYUBAR_DIR/scripts/helpers/theme.sh"

if [[ ! -x "$THEME_MANAGER" ]]; then
    echo "ERROR: Theme manager not found:"
    echo "  $THEME_MANAGER"
    exit 1
fi

# -------------------------------------
# KDE check
# -------------------------------------

if [[ "${XDG_CURRENT_DESKTOP:-}" != *"KDE"* ]]; then
    log "Warning: KDE Plasma not detected"
fi

# -------------------------------------
# Dependency check
# -------------------------------------

check_dependency() {
    local dependency="$1"

    if ! command -v "$dependency" >/dev/null 2>&1; then
        echo "ERROR: Missing dependency: $dependency"
        return 1
    fi

    log "Dependency OK: $dependency"
}
if [[ -z "${QDBUS:-}" ]]; then
    echo "ERROR: Missing dependency: qdbus or qdbus6"
    exit 1
fi

log "Using D-Bus command: $QDBUS"

DEPENDENCIES=(
    polybar
    kdialog
)

log "Checking dependencies..."

missing_dependencies=()

for dependency in "${DEPENDENCIES[@]}"; do
    if ! check_dependency "$dependency"; then
        missing_dependencies+=("$dependency")
    fi
done

if (( ${#missing_dependencies[@]} > 0 )); then
    echo
    echo "RyuBar cannot start."
    echo
    echo "Missing dependencies:"

    for dependency in "${missing_dependencies[@]}"; do
        echo "  - $dependency"
    done

    echo
    exit 1
fi

log "Applying RyuBar theme"
"$THEME_MANAGER"

OPTIONAL_DEPENDENCIES=(
    dolphin
    konsole
    firefox
    nmcli
    bluetoothctl
    wpctl
)

echo
echo "Checking optional dependencies..."

for dependency in "${OPTIONAL_DEPENDENCIES[@]}"; do
    if command -v "$dependency" >/dev/null 2>&1; then
        log "Optional dependency available: $dependency"
    else
        log "Optional dependency not available: $dependency"
    fi
done

log "All dependencies are available"

# -------------------------------------
# Configure Polybar symlink
# -------------------------------------

if [[ -L "$POLYBAR_LINK" ]]; then
CURRENT_TARGET="$(readlink -f "$POLYBAR_LINK" 2>/dev/null || true)"
EXPECTED_TARGET="$(readlink -f "$POLYBAR_DIR")"

    if [[ "$CURRENT_TARGET" == "$EXPECTED_TARGET" ]]; then
    log "Polybar symlink already configured"
    else
    echo
    echo "ERROR: Existing Polybar symlink points elsewhere:"
    echo "  $CURRENT_TARGET"
    echo
    echo "Expected:"
    echo "  $EXPECTED_TARGET"
    echo
    echo "RyuBar will not overwrite another Polybar configuration."
    exit 1
    fi

elif [[ -e "$POLYBAR_LINK" ]]; then

    if [[ -e "$BACKUP_DIR" ]]; then
        echo "ERROR: Polybar configuration already exists:"
        echo "  $POLYBAR_LINK"
        echo
        echo "A backup also already exists:"
        echo "  $BACKUP_DIR"
        echo
        echo "Nothing was changed."
        exit 1
    fi

    log "Backing up existing Polybar configuration"

    mv "$POLYBAR_LINK" "$BACKUP_DIR"

    ln -s "$POLYBAR_DIR" "$POLYBAR_LINK"

    log "Previous Polybar configuration backed up"

else

    ln -s "$POLYBAR_DIR" "$POLYBAR_LINK"

    log "Polybar symlink created"
fi

# -------------------------------------
# Stop previous Polybar instances
# -------------------------------------

log "Stopping previous Polybar instances"

pkill -x polybar 2>/dev/null || true

sleep 1

# -------------------------------------
# Start RyuBar
# -------------------------------------

log "Starting Polybar"

POLYBAR_LOG="$RYUBAR_DIR/logs/polybar.log"

polybar ryubar >"$POLYBAR_LOG" 2>&1 &
POLYBAR_PID=$!

sleep 1

if ! kill -0 "$POLYBAR_PID" 2>/dev/null; then
    echo
    echo "ERROR: Polybar failed to start."
    echo
    echo "Try running:"
    echo
    echo "    polybar ryubar"
    echo
    exit 1
fi
 
log "RyuBar started successfully"
log "Polybar PID: $POLYBAR_PID"

exit 0