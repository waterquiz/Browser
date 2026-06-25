FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    RESOLUTION=1366x768x24 \
    HOME=/root

# ── Install only what's needed ────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    chromium \
    fonts-liberation \
    fonts-dejavu-core \
    procps \
    curl \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── noVNC auto-connect page ───────────────────────────────────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html
COPY novnc-index.html /usr/share/novnc/index.html

# ── Chromium policy: force-install Violentmonkey ─────────────────────────────
RUN mkdir -p /etc/chromium/policies/managed
COPY policy.json /etc/chromium/policies/managed/policy.json

# ── Download & unpack Violentmonkey CRX (pre-installed, no internet needed) ──
RUN mkdir -p /opt/extensions/violentmonkey && \
    wget -q -O /tmp/vm.crx \
    "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=120.0.0.0&acceptformat=crx3&x=id%3Djinjaccalgkegednnccohejagnlnfdag%26installsource%3Dondemand%26uc" && \
    cd /opt/extensions/violentmonkey && \
    # CRX3 has a header — strip it and unzip
    python3 -c "
import sys, struct, zipfile, io
data = open('/tmp/vm.crx','rb').read()
# Find PK zip magic bytes
pk = data.find(b'PK')
if pk == -1: sys.exit(1)
zdata = data[pk:]
with zipfile.ZipFile(io.BytesIO(zdata)) as z:
    z.extractall('/opt/extensions/violentmonkey')
print('Violentmonkey unpacked OK')
" && \
    rm -f /tmp/vm.crx

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
