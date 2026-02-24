# GhostWire Easy Installer

**[📖 فارسی / Persian](README_FA.md)**

A friendly, step-by-step installer for [GhostWire](https://github.com/FrenchToblerone54/Ghostwire) — an anti-censorship reverse tunnel system. The script auto-detects whether you are in Iran or abroad and walks you through the correct setup with clear explanations at every step.

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
2. Configuring WebSocket port, port mappings, auto-update, and optional web panel
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
2. Entering the Iran server URL and authentication token
3. Installing a systemd service

---

## What the Installer Asks (Iran Server)

| Question       | Default            | Explanation                                                                                                |
| -------------- | ------------------ | ---------------------------------------------------------------------------------------------------------- |
| WebSocket host | `127.0.0.1`        | Use `127.0.0.1` if using nginx (recommended). Use `0.0.0.0` for direct connections.                        |
| WebSocket port | `8443`             | Port the abroad client connects to                                                                         |
| Port mappings  | `8080=80,8443=443` | `IRAN_PORT=INTERNET_PORT` — traffic arriving on IRAN_PORT is forwarded to INTERNET_PORT on the abroad side |
| Auto-update    | `Y`                | GhostWire checks GitHub for updates and restarts itself                                                    |
| Web panel      | `Y`                | Browser-based dashboard for monitoring and control                                                         |

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
| Auto-update | Same as server — recommended to keep enabled                                          |

---

## After Installation

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
