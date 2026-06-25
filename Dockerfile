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
    dbus \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Chromium (lightest browser with extension support) ───────────────────────
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-sandbox \
    --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Set root password ────────────────────────────────────────────────────────
RUN echo "root:root" | chpasswd

# ── Allow root X11 access ────────────────────────────────────────────────────
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config

# ── XRDP: allow root login ───────────────────────────────────────────────────
RUN adduser xrdp ssl-cert 2>/dev/null || true

# Allow root in sesman
RUN sed -i 's/^AllowRootLogin=false/AllowRootLogin=true/' /etc/xrdp/sesman.ini && \
    grep -q "^AllowRootLogin" /etc/xrdp/sesman.ini || \
    echo "AllowRootLogin=true" >> /etc/xrdp/sesman.ini

# Use Xorg (not Xvnc) — more stable
RUN sed -i 's/^#.*Xorg.*$//' /etc/xrdp/xrdp.ini || true && \
    sed -i 's/^port=.*/port=3389/' /etc/xrdp/xrdp.ini

# ── XFCE4 session — CRITICAL FIX ────────────────────────────────────────────
# Must use "exec" so session doesn't exit immediately
RUN echo "#!/bin/bash"                          > /root/.xsession && \
    echo "export XDG_SESSION_TYPE=x11"         >> /root/.xsession && \
    echo "export XDG_CURRENT_DESKTOP=XFCE"     >> /root/.xsession && \
    echo "unset DBUS_SESSION_BUS_ADDRESS"       >> /root/.xsession && \
    echo "exec startxfce4"                      >> /root/.xsession && \
    chmod +x /root/.xsession

# Also set for xrdp specifically
RUN echo "exec startxfce4" > /root/.Xclients && chmod +x /root/.Xclients

# Disable xfce4 first-run wizard so desktop appears immediately
RUN mkdir -p /root/.config/xfce4 && \
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml

RUN echo '[Desktop]'                              > /root/.config/xfce4/desktop.conf && \
    echo 'session=xfce'                          >> /root/.config/xfce4/desktop.conf

# ── Chromium enterprise policy ───────────────────────────────────────────────
RUN mkdir -p /etc/chromium/policies/managed
COPY chromium-policy/managed/policy.json /etc/chromium/policies/managed/policy.json

# ── PulseAudio client config ─────────────────────────────────────────────────
RUN mkdir -p /root/.config/pulse
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
