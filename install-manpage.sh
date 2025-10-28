#!/bin/bash

# Install Punk_OS Man Page
# This script installs the punk_os man page so users can run: man punk_os

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAN_SOURCE="${SCRIPT_DIR}/punk_os.1"

# Check if man page source exists
if [ ! -f "$MAN_SOURCE" ]; then
    echo_error "Man page source not found: $MAN_SOURCE"
    exit 1
fi

echo_info "Installing Punk_OS man page..."

# Determine installation directory
# Try /usr/local/man/man1 first (preferred for local installations)
# Fall back to /usr/share/man/man1 if needed
if [ -d "/usr/local/man/man1" ] || sudo mkdir -p /usr/local/man/man1 2>/dev/null; then
    MAN_DIR="/usr/local/man/man1"
elif [ -d "/usr/share/man/man1" ] || sudo mkdir -p /usr/share/man/man1 2>/dev/null; then
    MAN_DIR="/usr/share/man/man1"
else
    echo_error "Could not find or create man page directory"
    exit 1
fi

echo_info "Installing to: $MAN_DIR"

# Copy man page
sudo cp "$MAN_SOURCE" "$MAN_DIR/punk_os.1"
sudo chmod 644 "$MAN_DIR/punk_os.1"

echo_info "Man page file installed"

# Update man database
echo_info "Updating man database..."
if command -v mandb >/dev/null 2>&1; then
    sudo mandb -q 2>/dev/null || sudo mandb
elif command -v makewhatis >/dev/null 2>&1; then
    sudo makewhatis
else
    echo_warn "Could not update man database automatically"
    echo_warn "You may need to run: sudo mandb"
fi

echo ""
echo_info "✅ Installation complete!"
echo_info ""
echo_info "You can now run: ${GREEN}man punk_os${NC}"
echo_info ""
echo_info "To uninstall later, run:"
echo_info "  sudo rm $MAN_DIR/punk_os.1"
echo_info "  sudo mandb"
echo ""

# Test if man page is accessible
if man -w punk_os >/dev/null 2>&1; then
    echo_info "✅ Man page is accessible and ready to use!"
else
    echo_warn "Man page installed but may not be immediately accessible"
    echo_warn "Try logging out and back in, or running: sudo mandb"
fi
