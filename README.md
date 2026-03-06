# GhostWire Easy Installer

**[📖 فارسی / Persian](README_FA.md)**

A friendly, step-by-step installer for [GhostWire](https://github.com/FrenchToblerone54/Ghostwire) — an anti-censorship reverse tunnel system. The script auto-detects whether you are in Iran or abroad and walks you through the correct setup with clear explanations at every step.

## Demo Video

[![GhostWire Installation Demo](https://img.youtube.com/vi/t4lfe7dBP_c/maxresdefault.jpg)](https://youtu.be/t4lfe7dBP_c)

---

## What is GhostWire?

GhostWire is a reverse tunnel that lets people inside Iran access the internet freely.

```
[User in Iran] → [Iran Server] ←WebSocket Tunnel→ [Abroad Client] → [Internet]
```

- **Iran Server** — listens on local ports, accepts the tunnel connection from the abroad client
- **Abroad Client** — connects TO the Iran server, forwards traffic to the open internet

The key insight: Iran blocks _outbound_ connections to foreign servers, but it can still _receive inbound_ connections. The abroad client connects inbound to Iran, creating the tunnel.

---

## Requirements

|              | Iran Server                                       | Abroad Client                                      |
| ------------ | ------------------------------------------------- | -------------------------------------------------- |
| **Location** | VPS inside Iran with public IP                    | VPS outside Iran (Netherlands, Germany, USA, etc.) |
| **OS**       | Linux x86_64 (Ubuntu 22.04+)                      | Linux x86_64 (Ubuntu 22.04+)                       |
| **Access**   | `sudo` / root                                     | `sudo` / root                                      |
| **Optional** | A domain name + Cloudflare for better reliability | —                                                  |

---

## Quick Start

### Step 1 — On your Iran server

```bash
wget https://raw.githubusercontent.com/FrenchToblerone54/GhostwireInstaller/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

The script detects your location, confirms you want **Iran Server** mode, then walks you through:

1. Downloading and verifying the GhostWire server binary
2. Configuring WebSocket port, tunnel mode (`reverse` or `direct`), port mappings on the listener side, WebSocket pool size, auto-update, and optional web panel
3. Installing a systemd service so GhostWire starts automatically
4. Optional nginx reverse proxy with Let's Encrypt TLS

**Save the authentication token shown at the end — you need it for the abroad client.**

---

### Step 2 — On your abroad server (Netherlands, Germany, USA, etc.)

```bash
wget https://raw.githubusercontent.com/FrenchToblerone54/GhostwireInstaller/main/setup.sh -O setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

The script detects your location, confirms you want **Abroad Client** mode, then walks you through:

1. Downloading and verifying the GhostWire client binary
2. Entering the Iran server URL and authentication token, and matching tunnel mode settings
3. Installing a systemd service

---

## What the Installer Asks (Iran Server)

| Question       | Default            | Explanation                                                                                                |
| -------------- | ------------------ | ---------------------------------------------------------------------------------------------------------- |
| WebSocket host | `127.0.0.1`        | Use `127.0.0.1` if using nginx (recommended). Use `0.0.0.0` for direct connections.                        |
| WebSocket port | `8443`             | Port the abroad client connects to                                                                         |
| Tunnel mode    | `reverse`          | `reverse` (default) or `direct`                                                                            |
| Port mappings  | `8080=80,8443=443` | Asked only when server is listener (`reverse`)                                                              |
| ws_pool_children | `8`              | Number of worker processes handling connections — recommended: 4× your simultaneous user count             |
| Auto-update    | `Y`                | GhostWire checks GitHub for updates and restarts itself                                                    |
| Web panel      | `Y`                | Browser-based dashboard for monitoring and control                                                         |

> **Security tip:** Keep **Auto-update enabled** (`Y`) in the configuration. GhostWire receives security patches automatically — disabling it means you must manually update to stay protected.

**Port mapping examples:**

```
8080=80          Iran port 8080 → internet port 80
8443=443         Iran port 8443 → internet port 443
9000=1.1.1.1:53  Iran port 9000 → 1.1.1.1:53
8000-8100=3000   Port range forwarding
```

---

## What the Installer Asks (Abroad Client)

| Question    | Explanation                                                                           |
| ----------- | ------------------------------------------------------------------------------------- |
| Server URL  | URL of your Iran server, e.g. `wss://tunnel.example.com/ws` or `ws://1.2.3.4:8443/ws` |
| Token       | The token saved from the Iran server installation                                     |
| Tunnel mode | Must match server: `reverse` or `direct`                                              |
| Port mappings | Asked only when client is listener (`direct`)                                       |
| Auto-update | Same as server — recommended to keep enabled                                          |

---

## Mode Guide (Which Option for What?)

- Host a website on your own computer (client side) and expose it from server to WWW:
- Choose `mode=reverse`, then configure mappings on the **server** installer side.

- Connect to a VPN running on the server side, securely over GhostWire tunnel encryption:
- Choose `mode=direct`, then configure mappings on the **client** installer side.

- Default behavior: `reverse` (recommended default and still supported).

WS pool works in direct modes as well when using WebSocket transport.

For direct mode egress proxying, set these on server config (`/etc/ghostwire/server.toml`):

```toml
direct_http_proxy="http://127.0.0.1:8080"
direct_https_proxy="http://127.0.0.1:8080"
```

---

## After Installation

### Verify the connection first

Before setting up the abroad client, run this from your **abroad server** to confirm the Iran server's WebSocket endpoint is reachable:

```bash
curl -v https://YOUR-IRAN-DOMAIN/ws
```

> [!TIP]
> If curl fails, try enabling [Cloudflare proxy](#cloudflare-tips) on your domain and retry after a few minutes for DNS to propagate.

If it fails (connection refused, 502, timeout), check:
- If `listen_host` is `127.0.0.1` in `server.toml`, nginx must be correctly set up to proxy `/ws` — a failure here usually means nginx was misconfigured
- If using direct mode (`0.0.0.0`), ensure the port is open in your firewall

### Useful commands

**Iran Server:**

```bash
sudo systemctl status ghostwire-server
sudo systemctl restart ghostwire-server
sudo journalctl -u ghostwire-server -f
sudo ghostwire-server update
```

**Abroad Client:**

```bash
sudo systemctl status ghostwire-client
sudo systemctl restart ghostwire-client
sudo journalctl -u ghostwire-client -f
sudo ghostwire-client update
```

### Configuration files

- Iran server: `/etc/ghostwire/server.toml`
- Abroad client: `/etc/ghostwire/client.toml`

To retrieve your token later:

```bash
grep token /etc/ghostwire/server.toml
```

---

## Cloudflare Tips

If you use Cloudflare in front of your Iran server domain:

- **Network → WebSockets**: Must be **ON**
- **SSL/TLS → Overview**: Set to **Full (Strict)**
- **Speed → Rocket Loader**: Turn **OFF**
- **Speed → Auto Minify**: Disable all

On the abroad client, edit `/etc/ghostwire/client.toml` and set:

```toml
[cloudflare]
enabled=true
max_connection_time=1740
```

---

## Manual Location Override

The script detects your country via IP. If detection is wrong, simply choose the correct mode when prompted — the script always shows the detected location and asks for confirmation before doing anything.

---

## License

MIT — see [GhostWire repository](https://github.com/FrenchToblerone54/Ghostwire) for full details.
