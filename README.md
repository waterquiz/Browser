# Debian XRDP — Sports Browser Edition 🏆

A Dockerized **Debian Bullseye** desktop with XRDP remote access and **Chromium** browser pre-configured with sports sites.

## Features
- 🖥️ Full XFCE4 desktop via RDP (port 3389)
- 🌐 **Chromium** (lightest browser with extension support)
- ⚽ Sports bookmarks: LiveScore, SofaScore, FlashScore, ESPN, BBC Sport, Sky Sports
- 🛡️ uBlock Origin pre-installed via policy
- 📌 Homepage: LiveScore.com

## Quick Connect (after Railway deploy)

Open **Windows Remote Desktop** (Win+R → `mstsc`):
```
Computer: YOUR_RAILWAY_HOST:PORT
Username: root
Password: root
```

## Deploy to Railway

1. Fork or push this repo to your GitHub
2. Go to [railway.com](https://railway.com) → **New Project** → **Deploy from GitHub Repo**
3. Select this repo — Railway auto-detects the Dockerfile
4. In **Settings → Networking** → Add **TCP Proxy** → Port **3389**
5. Wait for build (~3–5 min), then connect via RDP!

## Local Test (Docker)

```bash
docker build -t sports-xrdp .
docker run -d -p 3389:3389 --name sports-xrdp sports-xrdp
# Connect: mstsc /v:localhost:3389
```

## Credentials
| Field    | Value  |
|----------|--------|
| Username | root   |
| Password | root   |

> ⚠️ Change the password in Dockerfile for production use.
