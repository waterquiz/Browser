FROM debian:bookworm-slim

LABEL maintainer="waterquiz"
LABEL description="Lightweight Debian XFCE desktop in browser via noVNC"

ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWORD=debian \
    RESOLUTION=1280x720x24 \
    VNC_PORT=5900 \
    DISPLAY=:1 \
    HOME=/root \
    USER=root

# ── Single-layer install (faster builds, smaller image) ──────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Virtual display
    xvfb \
    # VNC server (lightweight)
    x11vnc \
    # Minimal XFCE desktop
    xfce4 \
    xfce4-terminal \
    xfwm4 \
    xfdesktop4 \
    # noVNC + websocket proxy
    novnc \
    websockify \
    # Process supervisor
    supervisor \
    # X11 utils
    dbus-x11 \
    x11-xserver-utils \
    x11-utils \
    # Tools
    curl \
    wget \
    nano \
    procps \
    # Chromium browser
    chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── noVNC: point root to the noVNC web UI ────────────────────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── XFCE4 autostart: disable first-run wizard ────────────────────────────────
RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml \
             /root/.config/autostart \
             /root/Desktop

# Skip XFCE first-run / welcome screens
RUN echo '[Desktop Entry]'                              > /root/.config/autostart/skip-welcome.desktop && \
    echo 'Hidden=true'                                 >> /root/.config/autostart/skip-welcome.desktop

# ── Chromium policy: sports sites + uBlock Origin ────────────────────────────
RUN mkdir -p /etc/chromium/policies/managed
COPY chromium-policy/managed/policy.json /etc/chromium/policies/managed/policy.json

# ── Desktop shortcut: Sports Browser ─────────────────────────────────────────
COPY shortcuts/chromium-sports.desktop /root/Desktop/chromium-sports.desktop
RUN chmod +x /root/Desktop/chromium-sports.desktop

# ── Supervisor config: manages all processes ──────────────────────────────────
COPY supervisord.conf /etc/supervisor/conf.d/desktop.conf

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
