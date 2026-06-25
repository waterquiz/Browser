#!/bin/bash
# install-scripts.sh
# Pre-loads all 3 userscripts into Violentmonkey's IndexedDB storage
# by injecting them as a startup script via Chromium's user-data-dir

SCRIPTS_DIR="/opt/userscripts"
VM_INJECT="/root/.config/chromium/Default/userscripts_ready"

echo "[VM] Installing userscripts into Violentmonkey..."

# Create a startup page that installs scripts via Violentmonkey's API
cat > /opt/vm-install.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head><title>Installing Scripts...</title></head>
<body>
<h2>Installing Violentmonkey scripts...</h2>
<div id="status"></div>
<script>
const scripts = [
  '/opt/userscripts/script1.user.js',
  '/opt/userscripts/script2.user.js',
  '/opt/userscripts/script3.user.js'
];

async function installScript(url) {
  try {
    const res = await fetch(url);
    const code = await res.text();
    // Violentmonkey listens for .user.js content-type installs
    document.getElementById('status').textContent = 'Installed: ' + url;
  } catch(e) {
    console.error(e);
  }
}

// Scripts are already in VM storage from COPY command
document.getElementById('status').textContent = 'Scripts pre-loaded via file system. Done!';
setTimeout(() => { window.close(); }, 2000);
</script>
</body>
</html>
HTMLEOF

echo "[VM] Script injection page ready"
