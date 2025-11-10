#!/bin/bash

# One-Click Starter for social-auto-upload

# Configure the Conda environment name used by both services.
CONDA_ENV_NAME="social-auto-upload"

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "[ERROR] Could not find 'conda' on PATH."
    echo "Please install Anaconda/Miniconda or add Conda to PATH, then rerun this script."
    exit 1
fi

echo "=================================================="
echo " Starting social-auto-upload Servers..."
echo "=================================================="
echo ""

echo "Using Conda environment: $CONDA_ENV_NAME"
echo ""

echo "[1/2] Starting Python Backend Server in a new terminal..."

# Detect if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use osascript to open new Terminal windows
    osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD\" && conda activate $CONDA_ENV_NAME && python sau_backend.py"
end tell
EOF

    echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
    osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD/sau_frontend\" && npm run dev -- --host 0.0.0.0"
    activate
end tell
EOF
else
    # Linux - try common terminal emulators
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "conda activate $CONDA_ENV_NAME && python sau_backend.py; exec bash" &
        echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
        gnome-terminal -- bash -c "cd sau_frontend && npm run dev -- --host 0.0.0.0; exec bash" &
    elif command -v xterm &> /dev/null; then
        xterm -hold -e "conda activate $CONDA_ENV_NAME && python sau_backend.py" &
        echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
        xterm -hold -e "cd sau_frontend && npm run dev -- --host 0.0.0.0" &
    else
        echo "[WARNING] Could not find a terminal emulator."
        echo "Please run the following commands manually in separate terminals:"
        echo "  Terminal 1: conda activate $CONDA_ENV_NAME && python sau_backend.py"
        echo "  Terminal 2: cd sau_frontend && npm run dev -- --host 0.0.0.0"
        exit 1
    fi
fi

echo ""
echo "=================================================="
echo " Done."
echo " Two new terminal windows have been opened for"
echo " the backend and frontend servers."
echo " You can monitor logs there."
echo "=================================================="
echo ""

echo "This window will close in 10 seconds..."
sleep 10
