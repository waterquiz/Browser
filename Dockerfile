FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    RESOLUTION=1366x768x24 \
    HOME=/root

# ── Install everything needed ─────────────────────────────────────────────────
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

# ── noVNC: set auto-connect page ─────────────────────────────────────────────
COPY novnc-index.html /usr/share/novnc/index.html

# ── Chromium policy: force-install Violentmonkey from Chrome Web Store ────────
RUN mkdir -p /etc/chromium/policies/managed
COPY policy.json /etc/chromium/policies/managed/policy.json

# ── Download & unpack Violentmonkey extension ─────────────────────────────────
RUN mkdir -p /opt/extensions/violentmonkey && \
    wget -q --tries=3 -O /tmp/vm.crx \
      "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=120.0.0.0&acceptformat=crx3&x=id%3Djinjaccalgkegednnccohejagnlnfdag%26installsource%3Dondemand%26uc" && \
    python3 -c "import zipfile,io; d=open('/tmp/vm.crx','rb').read(); pk=d.find(b'PK'); zipfile.ZipFile(io.BytesIO(d[pk:])).extractall('/opt/extensions/violentmonkey')" && \
    rm -f /tmp/vm.crx && \
    echo "Violentmonkey installed OK"

# ── Copy the 3 userscripts into the container ────────────────────────────────
RUN mkdir -p /opt/userscripts
COPY userscripts/ /opt/userscripts/

# ── Copy autoinstall page & startup dirs ─────────────────────────────────────
COPY vm-autoinstall.html /opt/vm-autoinstall.html
RUN mkdir -p /root/.config/chromium/Default

# ── Startup script ────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
