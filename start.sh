#!/bin/bash
set -e

echo "================================================"
echo "  🖥️  Browser Desktop — noVNC Edition"
echo "================================================"

# ── Use Railway's injected PORT, fallback to 6080 ────────────────────────────
HTTP_PORT="${PORT:-6080}"
VNC_PORT="${VNC_PORT:-5900}"
RESOLUTION="${RESOLUTION:-1280x720x24}"
VNC_PASSWORD="${VNC_PASSWORD:-debian}"

echo "  HTTP Port  : $HTTP_PORT"
echo "  VNC Port   : $VNC_PORT"
echo "  Resolution : $RESOLUTION"
echo "================================================"

# ── Fix tmp permissions ───────────────────────────────────────────────────────
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# ── Start D-Bus ───────────────────────────────────────────────────────────────
mkdir -p /run/dbus
dbus-daemon --system --fork 2>/dev/null || true
sleep 1

# ── Start Xvfb (virtual display) ─────────────────────────────────────────────
Xvfb :1 -screen 0 ${RESOLUTION} -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2
echo "[OK] Xvfb started (DISPLAY=:1)"

# ── Set up VNC password ───────────────────────────────────────────────────────
mkdir -p ~/.vnc
x11vnc -storepasswd "${VNC_PASSWORD}" ~/.vnc/passwd
echo "[OK] VNC password set"

# ── Start x11vnc (VNC server) ─────────────────────────────────────────────────
x11vnc \
    -display :1 \
    -rfbauth ~/.vnc/passwd \
    -rfbport ${VNC_PORT} \
    -forever \
    -shared \
    -noxdamage \
    -noxfixes \
    -noxrecord \
    -nocursor \
    -quiet \
    -bg
sleep 1
echo "[OK] x11vnc started on port ${VNC_PORT}"

# ── Start XFCE4 desktop ───────────────────────────────────────────────────────
DISPLAY=:1 startxfce4 &
XFCE_PID=$!
sleep 3
echo "[OK] XFCE4 started"

# ── Set wallpaper / basic XFCE settings ──────────────────────────────────────
DISPLAY=:1 xsetroot -solid "#1a1a2e" 2>/dev/null || true

# ── Auto-launch Chromium on startup ──────────────────────────────────────────
sleep 2
DISPLAY=:1 chromium \
    --no-sandbox \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --no-first-run \
    --no-default-browser-check \
    --start-maximized \
    https://www.livescore.com &
echo "[OK] Chromium launched → LiveScore"

# ── Start noVNC / websockify (HTTP → VNC bridge) ─────────────────────────────
echo ""
echo "================================================"
echo "  ✅ Desktop ready!"
echo "  Open in browser: http://YOUR_URL:${HTTP_PORT}"
echo "  Password: ${VNC_PASSWORD}"
echo "================================================"

websockify \
    --web=/usr/share/novnc \
    --heartbeat=30 \
    ${HTTP_PORT} \
    localhost:${VNC_PORT}
