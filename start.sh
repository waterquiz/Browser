#!/bin/bash

PORT="${PORT:-8080}"
VNC_PORT=5900
RESOLUTION="${RESOLUTION:-1366x768x24}"
START_URL="${START_URL:-https://www.livescore.com}"

echo "======================================"
echo " Browser starting on Railway..."
echo " Resolution : $RESOLUTION"
echo " Start URL  : $START_URL"
echo "======================================"

# ── Tmp permissions ───────────────────────────────────────────────────────────
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# ── Start virtual display ─────────────────────────────────────────────────────
Xvfb :1 \
    -screen 0 ${RESOLUTION} \
    -ac \
    -nolisten tcp \
    +extension RANDR \
    &
sleep 2
echo "[OK] Virtual display started"

# ── Set up VNC (no password — Railway URL is already private) ─────────────────
x11vnc \
    -display :1 \
    -nopw \
    -listen localhost \
    -rfbport ${VNC_PORT} \
    -forever \
    -shared \
    -noxdamage \
    -noxfixes \
    -noxrecord \
    -quiet \
    -bg
sleep 1
echo "[OK] VNC server started"

# ── Launch Chromium with Violentmonkey + auto-install userscripts ─────────────
# First launch: open autoinstall page so VM installs the 3 scripts
# After install it auto-redirects to teaserfast.ru

FIRST_RUN_FLAG="/root/.config/chromium/.scripts_installed"

if [ ! -f "$FIRST_RUN_FLAG" ]; then
    OPEN_URL="file:///opt/vm-autoinstall.html"
    echo "[VM] First run — installing userscripts..."
else
    OPEN_URL="${START_URL:-https://teaserfast.ru}"
    echo "[VM] Scripts already installed — opening ${OPEN_URL}"
fi

DISPLAY=:1 chromium \
    --no-sandbox \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --no-first-run \
    --no-default-browser-check \
    --start-fullscreen \
    --window-size=1366,768 \
    --window-position=0,0 \
    --disable-infobars \
    --load-extension=/opt/extensions/violentmonkey \
    --user-data-dir=/root/.config/chromium \
    --allow-file-access-from-files \
    --allow-file-access \
    "${OPEN_URL}" \
    &
sleep 3

# Mark scripts as installed after first run
touch "$FIRST_RUN_FLAG"
echo "[OK] Chromium launched -> ${OPEN_URL}"

# ── Start noVNC (HTTP WebSocket bridge → user's browser) ─────────────────────
echo ""
echo "======================================"
echo " ✅ Ready! Open your Railway URL"
echo " Port: $PORT"
echo "======================================"

exec websockify \
    --web=/usr/share/novnc \
    --heartbeat=30 \
    --log-file=/dev/null \
    "0.0.0.0:${PORT}" \
    "localhost:${VNC_PORT}"
