#!/bin/bash
set -e

echo "============================================"
echo "  Debian XRDP Container Starting..."
echo "============================================"

# ── Fix /tmp/.X11-unix permissions ───────────────────────────────────────────
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# ── Start D-Bus ───────────────────────────────────────────────────────────────
if [ ! -f /var/run/dbus/pid ]; then
    mkdir -p /var/run/dbus
    dbus-daemon --system --fork
    echo "[OK] D-Bus started"
fi

# ── Start PulseAudio ──────────────────────────────────────────────────────────
pulseaudio --start \
    --exit-idle-time=-1 \
    --disallow-exit \
    --disable-shm \
    --log-target=syslog 2>/dev/null || \
    echo "[WARN] PulseAudio start failed (non-fatal)"

# ── Generate XRDP RSA keys if needed ─────────────────────────────────────────
if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp auto 2>/dev/null || true
fi

# ── Start XRDP ────────────────────────────────────────────────────────────────
service xrdp start
echo "[OK] XRDP started on port 3389"

# ── Health check loop ─────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  RDP ready — connect on port 3389"
echo "  Username: root"
echo "  Password: root"
echo "============================================"

# Keep container alive and watch xrdp
tail -f /var/log/xrdp.log 2>/dev/null || \
while true; do
    if ! service xrdp status > /dev/null 2>&1; then
        echo "[WARN] XRDP died, restarting..."
        service xrdp start
    fi
    sleep 10
done
