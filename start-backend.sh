#!/bin/bash

# SAU Backend Only Starter

# Configure the Conda environment name used by the backend.
CONDA_ENV_NAME="social-auto-upload"

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "[ERROR] Could not find 'conda' on PATH."
    echo "Please install Anaconda/Miniconda or add Conda to PATH, then rerun this script."
    exit 1
fi

echo "=================================================="
echo "  Starting social-auto-upload Backend Only..."
echo "=================================================="
echo ""

echo "Using Conda environment: $CONDA_ENV_NAME"
echo "[1/1] Starting Python Backend Server in a new terminal..."

# Detect if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use osascript to open a new Terminal window
    osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD\" && conda activate $CONDA_ENV_NAME && python sau_backend.py"
    activate
end tell
EOF
else
    # Linux - try common terminal emulators
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "conda activate $CONDA_ENV_NAME && python sau_backend.py; exec bash"
    elif command -v xterm &> /dev/null; then
        xterm -hold -e "conda activate $CONDA_ENV_NAME && python sau_backend.py" &
    else
        echo "[WARNING] Could not find a terminal emulator. Running in current terminal..."
        conda activate "$CONDA_ENV_NAME"
        python sau_backend.py
    fi
fi

echo ""
echo "Backend window launched. Monitor logs there and press Ctrl+C to stop."
echo "This launcher will close in 5 seconds..."
sleep 5
