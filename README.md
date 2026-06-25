# 🖥️ Browser Desktop — noVNC Sports Edition

A **lightweight** Debian Bookworm + XFCE4 desktop that opens directly in your **web browser** — no RDP client needed!

## ✨ Features

| Feature | Detail |
|---------|--------|
| 🖥️ Desktop | Debian Bookworm + XFCE4 (minimal) |
| 🌐 Browser-based | noVNC — opens in any browser tab |
| ⚡ Single HTTP port | Railway-ready (`$PORT` auto-detected) |
| 🔐 Password protected | Default: `debian` |
| ⚽ Sports pre-loaded | Chromium opens LiveScore on startup |
| 📌 Sports bookmarks | LiveScore, SofaScore, ESPN, BBC Sport, Sky Sports... |
| 🛡️ Ad blocker | uBlock Origin pre-installed |

## 🚀 Deploy on Railway

1. Push this repo to GitHub
2. [railway.com](https://railway.com) → **New Project** → **Deploy from GitHub Repo**
3. Select this repo — Railway auto-detects `Dockerfile`
4. Railway generates a public `*.up.railway.app` URL
5. Open that URL → click **Connect** → password: `debian`

## 🐳 Local Docker

```bash
docker build -t browser-desktop .
docker run -d -p 6080:6080 browser-desktop
```
Open **http://localhost:6080** → Connect → password: `debian`

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PASSWORD` | `debian` | Password for noVNC |
| `RESOLUTION` | `1280x720x24` | Screen resolution |
| `PORT` | `6080` | HTTP port (Railway sets automatically) |
| `VNC_PORT` | `5900` | Internal VNC port |

## Change Password (Railway Dashboard)

In Railway → your service → **Variables** → Add:
```
VNC_PASSWORD = yourpassword
```
