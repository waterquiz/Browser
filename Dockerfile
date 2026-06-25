FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root

# ── System base ─────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    x11-xserver-utils \
    xterm \
    procps \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Chromium (lightest browser with extension support) ───────────────────────
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-sandbox \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Allow root to login via XRDP ────────────────────────────────────────────
RUN echo "root:root" | chpasswd

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config 2>/dev/null || \
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

# ── XRDP: use Xorg backend, enable root ─────────────────────────────────────
RUN adduser xrdp ssl-cert 2>/dev/null || true && \
    sed -i 's/^port=.*/port=3389/' /etc/xrdp/xrdp.ini && \
    sed -i 's/^#AllowRootLogin.*/AllowRootLogin=true/' /etc/xrdp/sesman.ini && \
    sed -i 's/^AllowRootLogin=.*/AllowRootLogin=true/' /etc/xrdp/sesman.ini || \
    echo "AllowRootLogin=true" >> /etc/xrdp/sesman.ini

# ── XFCE4 session for XRDP ──────────────────────────────────────────────────
RUN echo "startxfce4" > /root/.xsession && chmod +x /root/.xsession

# ── Chromium enterprise policy: pre-install extensions ──────────────────────
# Extensions installed:
#   uBlock Origin        (cjpalhdlnbpafiamejdnhcphjbkeiagm)  - ad blocker
#   Sports Tracker       (install via force-install)
RUN mkdir -p /etc/chromium/policies/managed
COPY chromium-policy/managed/policy.json /etc/chromium/policies/managed/policy.json

# ── PulseAudio client config ─────────────────────────────────────────────────
COPY pulse-client.conf /root/.config/pulse/client.conf

# ── Desktop shortcuts ────────────────────────────────────────────────────────
RUN mkdir -p /root/Desktop
COPY shortcuts/chromium-sports.desktop /root/Desktop/chromium-sports.desktop
RUN chmod +x /root/Desktop/chromium-sports.desktop

# ── Startup script ───────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
