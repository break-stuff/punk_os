#!/bin/bash

# --- Configuration ---
KINTO_DIR="$HOME/Downloads/kinto-master"
PATCH_FILE="$KINTO_DIR/xkeysnail/xkeysnail/input.py"
INSTALL_SCRIPT="$KINTO_DIR/install/linux.sh"
SEARCH_PATTERN='\.fn'
REPLACE_PATTERN='\.path'

# --- Check Kinto directory existence ---
if [ ! -d "$KINTO_DIR" ]; then
    echo "Error: Kinto directory not found at $KINTO_DIR"
    echo "Please ensure kinto-master is extracted to ~/Downloads/"
    exit 1
fi

echo "Navigating to Kinto directory..."
cd "$KINTO_DIR" || exit

# --- Find the target file ---
echo "Searching for 'input.py' file..."

if [ -z "$PATCH_FILE" ]; then
    echo "Fatal Error: Could not locate the 'input.py' file to patch."
    exit 1
fi

echo "Found file: $PATCH_FILE"

# --- Patch the file ---
echo "Patching '$PATCH_FILE' by replacing '$SEARCH_PATTERN' with '$REPLACE_PATTERN'..."
# Use sed to perform the in-place replacement
# The -i.bak creates a backup file with a .bak extension
sudo sed -i.bak "s/$SEARCH_PATTERN/$REPLACE_PATTERN/g" "$PATCH_FILE"

if [ $? -eq 0 ]; then
    echo "Patch applied successfully."
else
    echo "Error applying patch with sed. Check permissions or file content."
    exit 1
fi

# --- Run the Kinto installer script ---
echo "Running the Kinto installer script: $INSTALL_SCRIPT"
if [ -f "$INSTALL_SCRIPT" ]; then
    # The installer often uses sudo, so running with sudo here might not be necessary, but check the script
    bash "$INSTALL_SCRIPT"
    if [ $? -eq 0 ]; then
        echo "Kinto installation/re-installation completed successfully."
        # Attempt to restart the service after successful install
        echo "Attempting to restart xkeysnail service..."
        sudo systemctl restart xkeysnail.service
    else
        echo "Kinto installer script failed."
    fi
else
    echo "Error: Installer script not found at $INSTALL_SCRIPT"
fi

echo "Patch complete!"
