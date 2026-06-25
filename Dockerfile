FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    RESOLUTION=1366x768x24 \
    HOME=/root

# ── Install ONLY what's needed (no full desktop) ─────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Virtual display
    xvfb \
    # Lightweight VNC server
    x11vnc \
    # noVNC web UI + websocket proxy
    novnc \
    websockify \
    # Chromium browser
    chromium \
    # Fonts so pages render correctly
    fonts-liberation \
    fonts-dejavu-core \
    # Basic tools
    procps \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── noVNC: set default page ──────────────────────────────────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── Custom noVNC auto-connect page ──────────────────────────────────────────
COPY novnc-index.html /usr/share/novnc/index.html

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
