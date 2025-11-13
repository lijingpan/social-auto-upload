#!/bin/bash

# One-Click Starter for social-auto-upload (macOS/Linux)

# Optional Conda environment name (if you use Conda)
CONDA_ENV_NAME="social-auto-upload"
USE_CONDA=0
if command -v conda &> /dev/null; then
  USE_CONDA=1
fi

echo "=================================================="
echo " Starting social-auto-upload Servers..."
echo "=================================================="
echo ""

echo "Using Conda: $USE_CONDA (env: $CONDA_ENV_NAME)"
echo ""

echo "[pre] Cleaning ports 5409/5173"
if command -v npx &> /dev/null; then
  npx kill-port 5409 5173 || true
else
  if command -v lsof &> /dev/null; then
    lsof -ti:5409 -ti:5173 | xargs kill -9 2>/dev/null || true
  fi
fi

echo "[pre] Ensuring Python virtualenv and dependencies"
if [ ! -d .venv ]; then
  if command -v python3 &> /dev/null; then
    python3 -m venv .venv || true
  else
    python -m venv .venv || true
  fi
fi
if [ -f requirements.txt ]; then
  source .venv/bin/activate 2>/dev/null || true
  pip install --upgrade pip >/dev/null 2>&1 || true
  pip install -r requirements.txt || pip3 install -r requirements.txt || true
  deactivate 2>/dev/null || true
fi

echo "[1/2] Starting Python Backend Server in a new terminal..."

# Detect if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use osascript to open new Terminal windows
    if [ "$USE_CONDA" = "1" ]; then
      osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD\" && conda activate $CONDA_ENV_NAME && python3 sau_backend.py"
end tell
EOF
    else
      osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD\" && if [ -d .venv ]; then source .venv/bin/activate; fi; python3 sau_backend.py"
end tell
EOF
    fi

    echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
    osascript <<EOF
tell application "Terminal"
    do script "cd \"$PWD/sau_frontend\" && (npm ci || npm install) && npm run dev -- --host 0.0.0.0"
    activate
end tell
EOF
else
    # Linux - try common terminal emulators
    if command -v gnome-terminal &> /dev/null; then
        if [ "$USE_CONDA" = "1" ]; then
          gnome-terminal -- bash -c "conda activate $CONDA_ENV_NAME && python sau_backend.py; exec bash" &
        else
          gnome-terminal -- bash -c "cd \"$PWD\" && if [ -d .venv ]; then source .venv/bin/activate; fi; python sau_backend.py; exec bash" &
        fi
        echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
        gnome-terminal -- bash -c "cd sau_frontend && npm run dev -- --host 0.0.0.0; exec bash" &
    elif command -v xterm &> /dev/null; then
        if [ "$USE_CONDA" = "1" ]; then
          xterm -hold -e "conda activate $CONDA_ENV_NAME && python sau_backend.py" &
        else
          xterm -hold -e "bash -lc 'cd "$PWD" && if [ -d .venv ]; then source .venv/bin/activate; fi; python sau_backend.py'" &
        fi
        echo "[2/2] Starting Vue.js Frontend Server in another new terminal..."
        xterm -hold -e "cd sau_frontend && npm run dev -- --host 0.0.0.0" &
    else
        echo "[WARNING] Could not find a terminal emulator."
        echo "Please run the following commands manually in separate terminals:"
        if [ "$USE_CONDA" = "1" ]; then
          echo "  Terminal 1: conda activate $CONDA_ENV_NAME && python sau_backend.py"
        else
          echo "  Terminal 1: (source .venv/bin/activate) && python sau_backend.py"
        fi
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

if command -v npx &> /dev/null; then
  echo "[health] Waiting for backend http://localhost:5409 ..."
  npx wait-on --timeout 60000 http://localhost:5409 || echo "[warn] backend health check timed out"
  echo "[health] Waiting for frontend http://localhost:5173 ..."
  npx wait-on --timeout 60000 http://localhost:5173 || echo "[warn] frontend health check timed out"
fi

echo "Backend: http://localhost:5409/"
echo "Frontend: http://localhost:5173/"

if [ "${RUN_E2E_TEST:-0}" = "1" ]; then
  if command -v python3 &> /dev/null; then
    python3 -m e2e.test_publish_center || true
  else
    python -m e2e.test_publish_center || true
  fi
fi
