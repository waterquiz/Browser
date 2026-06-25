#!/bin/bash
set -e

echo "============================================"
echo "  Debian XRDP Container Starting..."
echo "============================================"

# ── Fix /tmp permissions ──────────────────────────────────────────────────────
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
mkdir -p /run/dbus
chmod 755 /run/dbus

# ── Start D-Bus system bus ────────────────────────────────────────────────────
if [ ! -f /run/dbus/pid ]; then
    dbus-daemon --system --fork --print-pid > /run/dbus/pid 2>/dev/null || true
    sleep 1
    echo "[OK] D-Bus started"
else
    echo "[OK] D-Bus already running"
fi

# ── Fix XRDP RSA keys ─────────────────────────────────────────────────────────
if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp auto 2>/dev/null || true
    echo "[OK] XRDP keys generated"
fi

# ── Fix /var/run/xrdp ─────────────────────────────────────────────────────────
mkdir -p /var/run/xrdp
chmod 755 /var/run/xrdp

# ── Start XRDP sesman (session manager) first ────────────────────────────────
/usr/sbin/xrdp-sesman --nodaemon &
sleep 2
echo "[OK] XRDP sesman started"

# ── Start XRDP ────────────────────────────────────────────────────────────────
/usr/sbin/xrdp --nodaemon &
sleep 2
echo "[OK] XRDP started on port 3389"

# ── Start PulseAudio ──────────────────────────────────────────────────────────
pulseaudio --start \
    --exit-idle-time=-1 \
    --disallow-exit \
    --disable-shm 2>/dev/null || \
    echo "[WARN] PulseAudio start failed (non-fatal)"

echo ""
echo "============================================"
echo "  RDP ready — connect on port 3389"
echo "  Username: root"
echo "  Password: root"
echo "  Session:  Xorg  <-- select this in login!"
echo "============================================"

# ── Keep container alive ──────────────────────────────────────────────────────
wait
