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
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── noVNC auto-connect page ───────────────────────────────────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html
COPY novnc-index.html /usr/share/novnc/index.html

# ── Chromium policy: force-install Violentmonkey ─────────────────────────────
RUN mkdir -p /etc/chromium/policies/managed
COPY policy.json /etc/chromium/policies/managed/policy.json

# ── Download & unpack Violentmonkey CRX ──────────────────────────────────────
RUN mkdir -p /opt/extensions/violentmonkey && \
    wget -q -O /tmp/vm.crx \
    "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=120.0.0.0&acceptformat=crx3&x=id%3Djinjaccalgkegednnccohejagnlnfdag%26installsource%3Dondemand%26uc" && \
    python3 -c "
import sys, zipfile, io
data = open('/tmp/vm.crx','rb').read()
pk = data.find(b'PK')
if pk == -1: sys.exit(1)
with zipfile.ZipFile(io.BytesIO(data[pk:])) as z:
    z.extractall('/opt/extensions/violentmonkey')
print('Violentmonkey unpacked OK')
" && \
    rm -f /tmp/vm.crx

# ── Copy the 3 userscripts into the container ────────────────────────────────
RUN mkdir -p /opt/userscripts
COPY userscripts/ /opt/userscripts/

# ── Pre-build Violentmonkey's script storage (JSON file approach) ─────────────
# VM stores scripts in its extension storage. We create a custom startup page
# that auto-installs the scripts on first launch via the VM install API.
RUN mkdir -p /root/.config/chromium/Default && \
    cat > /opt/vm-autoinstall.js << 'JSEOF'
// This script runs on the VM background page context
// It installs the userscripts by opening install URLs
JSEOF

# ── Create an autoinstall HTML page served locally ───────────────────────────
COPY vm-autoinstall.html /opt/vm-autoinstall.html

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
