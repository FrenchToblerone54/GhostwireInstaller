#!/bin/bash
set -e

GITHUB_REPO="frenchtoblerone54/ghostwire"
GW_VERSION="latest"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
BOLD="\033[1m"
DIM="\033[2m"
NC="\033[0m"
INSTALL_MODE=""

p_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ============================================================"
    echo "    👻  GhostWire Easy Installer  |  Nasb-e Rahat            "
    echo "    Anti-Censorship Reverse Tunnel  |  Tunnel Zed-e Sansor   "
    echo "  ============================================================"
    echo -e "${NC}"
    echo -e "  ${DIM}Source: github.com/${GITHUB_REPO}${NC}"
    echo ""
}

p_step() {
    echo -e "\n${BLUE}${BOLD}▶  $1${NC}"
}

p_ok() {
    echo -e "  ${GREEN}✓${NC}  $1"
}

p_warn() {
    echo -e "  ${YELLOW}⚠${NC}  $1"
}

p_err() {
    echo -e "  ${RED}✗${NC}  $1" >&2
}

p_info() {
    echo -e "  ${CYAN}ℹ${NC}  $1"
}

p_ask() {
    echo -ne "  ${MAGENTA}?${NC}  $1"
}

p_sep() {
    echo -e "  ${DIM}------------------------------------------------------------${NC}"
}

p_token_box() {
    local token="$1"
    echo ""
    echo -e "  ${YELLOW}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${YELLOW}${BOLD}║  🔑  TOKEN - INO SAVE KON! (Save this!)                 ║${NC}"
    echo -e "  ${YELLOW}${BOLD}║                                                          ║${NC}"
    echo -e "  ${YELLOW}${BOLD}║  ${NC}${BOLD}${token}${NC}${YELLOW}${BOLD}  ║${NC}"
    echo -e "  ${YELLOW}${BOLD}║                                                          ║${NC}"
    echo -e "  ${YELLOW}${BOLD}║  ⚠  Baraye Client (Kharej) lazemesh dari!               ║${NC}"
    echo -e "  ${YELLOW}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

p_panel_box() {
    local url="$1"
    echo ""
    echo -e "  ${CYAN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}${BOLD}║  🖥  Web Management Panel                                ║${NC}"
    echo -e "  ${CYAN}${BOLD}║                                                          ║${NC}"
    echo -e "  ${CYAN}${BOLD}║  URL: ${NC}${url}${CYAN}${BOLD}  ║${NC}"
    echo -e "  ${CYAN}${BOLD}║                                                          ║${NC}"
    echo -e "  ${CYAN}${BOLD}║  In URL ro bookmark kon! (Bookmark this URL!)           ║${NC}"
    echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_prerequisites() {
    p_step "Pish-niaz-ha ro check mikonim... (Checking prerequisites)"
    if [ "$EUID" -ne 0 ]; then
        p_err "Bayad ba sudo ejra koni! Run with: sudo bash setup.sh"
        exit 1
    fi
    p_ok "Root access: OK"
    if [ "$(uname -m)" != "x86_64" ]; then
        p_err "Faqat x86_64 (64-bit) support mishe! (Only x86_64 is supported.)"
        exit 1
    fi
    p_ok "CPU: x86_64 - OK"
    if [ "$(uname -s)" != "Linux" ]; then
        p_err "Faqat Linux support mishe!"
        exit 1
    fi
    p_ok "OS: Linux - OK"
    if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
        p_err "curl ya wget lazem dari! Nasb kon: apt-get install -y curl"
        exit 1
    fi
    p_ok "curl/wget: OK"
}

fetch_url() {
    local url="$1"
    local out="$2"
    if command -v curl &>/dev/null; then
        curl -fsSL --max-time 10 "$url" -o "$out" 2>/dev/null
    else
        wget -q --timeout=10 "$url" -O "$out" 2>/dev/null
    fi
}

fetch_text() {
    local url="$1"
    if command -v curl &>/dev/null; then
        curl -s --max-time 8 "$url" 2>/dev/null || true
    else
        wget -qO- --timeout=8 "$url" 2>/dev/null || true
    fi
}

detect_country() {
    local country=""
    p_info "IP-e shoma ro detect mikonim... (Detecting your location)"
    country=$(fetch_text "https://ipapi.co/country_code/")
    [ ${#country} -eq 2 ] && { echo "$country"; return; }
    country=$(fetch_text "https://ipinfo.io/country" | tr -d '"' | tr -d ' ')
    [ ${#country} -eq 2 ] && { echo "$country"; return; }
    country=$(fetch_text "https://api.country.is/" | grep -o '"country":"[A-Z]*"' | grep -o '[A-Z]*"' | tr -d '"' || true)
    [ ${#country} -eq 2 ] && { echo "$country"; return; }
    local ip
    ip=$(fetch_text "https://api.ipify.org")
    [ -n "$ip" ] && country=$(fetch_text "https://ipapi.co/${ip}/country_code/")
    [ ${#country} -eq 2 ] && { echo "$country"; return; }
    echo "IR"
}

ask_location() {
    local detected
    detected=$(detect_country)
    local suggested_mode="KHAREJ"
    [ "$detected" = "IR" ] && suggested_mode="IRAN"
    p_step "Server shoma kojast? (Where is your server?)"
    p_sep
    if [ "$detected" = "IR" ]; then
        echo -e "  ${BLUE}ℹ${NC}  IP-e shoma az ${BLUE}${BOLD}IRAN${NC} detect shod. 🇮🇷"
        echo -e "  ${BLUE}ℹ${NC}  Pishnahad: ${BLUE}${BOLD}Iran Server (Server Mode)${NC}"
    else
        echo -e "  ${GREEN}ℹ${NC}  IP-e shoma az ${GREEN}${BOLD}Kharej${NC} detect shod. 🌍 (Country: ${detected})"
        echo -e "  ${GREEN}ℹ${NC}  Pishnahad: ${GREEN}${BOLD}Kharej Client (Client Mode)${NC}"
    fi
    p_sep
    echo ""
    echo -e "  ${BOLD}Lotfan entekhab konid (Please choose):${NC}"
    echo ""
    echo -e "  ${BLUE}${BOLD}1)${NC}  🇮🇷  ${BLUE}${BOLD}Iran Server${NC}"
    echo -e "       ${DIM}Server darun-e Iran - port-ha ro listen mikone${NC}"
    echo -e "       ${DIM}GhostWire inja nasb mishe va dar-e varoodi ro baz negah midare${NC}"
    echo ""
    echo -e "  ${GREEN}${BOLD}2)${NC}  🌍  ${GREEN}${BOLD}Kharej Client (Abroad)${NC}"
    echo -e "       ${DIM}Server birun az Iran - be Iran vasl mishe, internet ro forward mikone${NC}"
    echo -e "       ${DIM}GhostWire inja nasb mishe va traffic ro be internet miresone${NC}"
    echo ""
    local default_num="1"
    [ "$suggested_mode" = "KHAREJ" ] && default_num="2"
    local choice=""
    while true; do
        p_ask "Gozine-ye shoma (1 ya 2) [default: ${default_num}]: "
        read -r choice
        choice="${choice:-${default_num}}"
        case "$choice" in
            "1") INSTALL_MODE="IRAN"; break ;;
            "2") INSTALL_MODE="KHAREJ"; break ;;
            *) p_err "Lotfan 1 ya 2 bezan!" ;;
        esac
    done
    echo ""
    if [ "$INSTALL_MODE" = "IRAN" ]; then
        echo -e "  ${BLUE}✓${NC}  Mode: ${BLUE}${BOLD}Iran Server${NC} - nasb mikonim... 🇮🇷"
    else
        echo -e "  ${GREEN}✓${NC}  Mode: ${GREEN}${BOLD}Kharej Client${NC} - nasb mikonim... 🌍"
    fi
}

download_binary() {
    local bin_name="$1"
    local bin_url="https://github.com/${GITHUB_REPO}/releases/${GW_VERSION}/download/${bin_name}"
    local sha_url="${bin_url}.sha256"
    p_info "Daryaft: ${bin_name} (Downloading binary)"
    if command -v wget &>/dev/null; then
        wget -q --show-progress "$bin_url" -O "/tmp/${bin_name}"
        wget -q "$sha_url" -O "/tmp/${bin_name}.sha256"
    else
        curl -L --progress-bar "$bin_url" -o "/tmp/${bin_name}"
        curl -fsSL "$sha_url" -o "/tmp/${bin_name}.sha256"
    fi
    p_info "Hash-e file ro check mikonim... (Verifying checksum)"
    cd /tmp && sha256sum -c "${bin_name}.sha256"
    p_ok "File dorost darid - hash tamiz! (Checksum verified)"
    install -m 755 "/tmp/${bin_name}" "/usr/local/bin/${bin_name}"
    p_ok "Binary nasb shod dar: /usr/local/bin/${bin_name}"
}

install_systemd_service() {
    local svc_name="$1"
    local bin_path="/usr/local/bin/${svc_name}"
    local conf_path="/etc/ghostwire/${svc_name##ghostwire-}.toml"
    cat > "/etc/systemd/system/${svc_name}.service" <<EOF
[Unit]
Description=GhostWire ${svc_name}
After=network.target

[Service]
Type=simple
ExecStart=${bin_path} -c ${conf_path}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    p_ok "Systemd service sakhte shod: ${svc_name}.service"
}

start_service() {
    local svc_name="$1"
    systemctl enable "$svc_name"
    if systemctl is-active --quiet "$svc_name"; then
        systemctl restart "$svc_name"
        p_ok "Service restart shod: ${svc_name}"
    else
        systemctl start "$svc_name"
        p_ok "Service shoru shod: ${svc_name}"
    fi
}

configure_server() {
    p_step "Tanzim-ate server (Server configuration)"
    if [ -f /etc/ghostwire/server.toml ]; then
        p_warn "Config ghablan vojod dasht: /etc/ghostwire/server.toml"
        p_warn "Jadid nasazi - haman config ro negah midim."
        return
    fi
    p_info "GhostWire yek token rand (tasadofi) mikhad baraye amniyat."
    p_info "In token moshakhas mikone ke client-e kharej-e to-e!"
    local token
    token=$(/usr/local/bin/ghostwire-server --generate-token)
    echo ""
    p_sep
    echo -e "  ${BLUE}${BOLD}1. WebSocket Port - Dar-e Varoodi${NC}"
    p_info "Kharej server az in port be Iran vasl mishe."
    p_info "Agar nginx doshti: host = 127.0.0.1 (default, amniyat bishtar)"
    p_info "Agar nginx nadori: host = 0.0.0.0 (direct connection)"
    echo ""
    p_ask "WebSocket listen host [127.0.0.1]: "
    read -r WS_HOST
    WS_HOST="${WS_HOST:-127.0.0.1}"
    p_ask "WebSocket listen port [8443]: "
    read -r WS_PORT
    WS_PORT="${WS_PORT:-8443}"
    p_ok "WebSocket: ${WS_HOST}:${WS_PORT}"
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}2. Port Mapping - Che Port-hai Forward Beshe?${NC}"
    p_info "Misali: 8080=80   =>  Iran:8080 traffic ro be internet port 80 miresone"
    p_info "Misali: 8443=443  =>  Iran:8443 traffic ro be internet port 443 miresone"
    p_info "Misali: 8000-8100=80  =>  Port range forwarding"
    p_info "Misali: 9000=1.2.3.4:443  =>  Be yek IP-e khas forward kone"
    echo ""
    p_info "Agar proxy (like V2Ray, Xray) dar kharej dari:"
    p_info "  oon proxy-e kharej port X ro listen mikone"
    p_info "  Inja bezan: 443=X  (Iran 443 → kharej port X)"
    echo ""
    local tunnel_input=""
    while true; do
        p_ask "Port mapping-ha (ba comma joda kon) [8080=80,8443=443]: "
        read -r tunnel_input
        tunnel_input="${tunnel_input:-8080=80,8443=443}"
        [ -n "$tunnel_input" ] && break
        p_err "In ghesmat lazem-e!"
    done
    IFS="," read -ra TUNNELS <<< "$tunnel_input"
    TUNNELS=("${TUNNELS[@]// /}")
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}3. Auto-Update - Be-roozresani Khodkar${NC}"
    p_info "GhostWire az GitHub jadid-tarinha ro check mikone va khodesh update mishe."
    p_ask "Auto-update ro faal koni? [Y/n]: "
    read -r AUTO_UPDATE
    AUTO_UPDATE="${AUTO_UPDATE:-y}"
    if [[ "$AUTO_UPDATE" =~ ^[Yy]$ ]]; then
        AUTO_UPDATE="true"
        p_ok "Auto-update: Faal"
    else
        AUTO_UPDATE="false"
        p_warn "Auto-update: Gheyr-e Faal"
    fi
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}4. Web Panel - Pane-le Modiriyat${NC}"
    p_info "Yek interface grafiki baraye monitoring, log va control-e service."
    p_info "Amniyat: Faghat az localhost qabel-e dastres ast (baraye nginx proxy)."
    p_ask "Panel ro faal koni? [Y/n]: "
    read -r ENABLE_PANEL
    ENABLE_PANEL="${ENABLE_PANEL:-y}"
    local PANEL_ENABLED="false"
    local PANEL_HOST="127.0.0.1"
    local PANEL_PORT="9090"
    local PANEL_PATH=""
    local PANEL_CONFIG=""
    if [[ "$ENABLE_PANEL" =~ ^[Yy]$ ]]; then
        PANEL_ENABLED="true"
        p_ask "Panel host [127.0.0.1]: "
        read -r PANEL_HOST
        PANEL_HOST="${PANEL_HOST:-127.0.0.1}"
        p_ask "Panel port [9090]: "
        read -r PANEL_PORT
        PANEL_PORT="${PANEL_PORT:-9090}"
        PANEL_PATH=$(/usr/local/bin/ghostwire-server --generate-token)
        PANEL_CONFIG="
[panel]
enabled=true
host=\"${PANEL_HOST}\"
port=${PANEL_PORT}
path=\"${PANEL_PATH}\"
threads=4"
        p_ok "Panel: http://${PANEL_HOST}:${PANEL_PORT}/${PANEL_PATH}/"
    fi
    local TUNNEL_ARRAY
    TUNNEL_ARRAY=$(printf ',"%s"' "${TUNNELS[@]}")
    TUNNEL_ARRAY="[${TUNNEL_ARRAY:1}]"
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}Kholaseh-ye Config (Summary):${NC}"
    p_info "WebSocket: ${WS_HOST}:${WS_PORT}"
    p_info "Tunnels: ${TUNNEL_ARRAY}"
    p_info "Auto-update: ${AUTO_UPDATE}"
    [ "$PANEL_ENABLED" = "true" ] && p_info "Panel: http://${PANEL_HOST}:${PANEL_PORT}/${PANEL_PATH}/"
    echo ""
    p_ask "Confirm? Zakhire beshe? [Y/n]: "
    read -r CONFIRM
    CONFIRM="${CONFIRM:-y}"
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        p_err "Nasb cancel shod."
        exit 1
    fi
    mkdir -p /etc/ghostwire
    cat > /etc/ghostwire/server.toml <<EOF
[server]
protocol="websocket"
listen_host="${WS_HOST}"
listen_port=${WS_PORT}
listen_backlog=4096
websocket_path="/ws"
ping_interval=30
ping_timeout=60
ws_pool_enabled=true
ws_pool_children=8
ws_pool_min=2
ws_pool_stripe=false
udp_enabled=true
ws_send_batch_bytes=65536
auto_update=${AUTO_UPDATE}
update_check_interval=300
update_check_on_startup=true

[auth]
token="${token}"

[tunnels]
ports=${TUNNEL_ARRAY}

[logging]
level="info"
file="/var/log/ghostwire-server.log"${PANEL_CONFIG}
EOF
    p_ok "Config zakhire shod: /etc/ghostwire/server.toml"
    p_token_box "$token"
    if [ "$PANEL_ENABLED" = "true" ]; then
        p_panel_box "http://${PANEL_HOST}:${PANEL_PORT}/${PANEL_PATH}/"
    fi
}

setup_nginx_server() {
    p_step "Nginx Setup - Reverse Proxy (Optional)"
    p_info "Nginx yek in-dari (reverse proxy) ast ke connection-ha ro be GhostWire miresone."
    p_info "Fayde-ha: TLS/HTTPS, domain name, security bishtar."
    p_info "Agar domain nadari ya direct mikhai, skip kon."
    echo ""
    p_ask "Nginx ro setup koni? [y/N]: "
    read -r -n 1 REPLY
    echo ""
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        p_info "Nginx skip shod. Direct connection mode."
        p_info "Port WS-e server ro (${WS_PORT}) direct expose kon ya bad nasb kon."
        return
    fi
    p_info "Nasb-e nginx va certbot..."
    apt-get update -qq && apt-get install -y -qq nginx certbot python3-certbot-nginx
    p_ok "nginx va certbot nasb shod."
    if [ -f /etc/nginx/sites-available/ghostwire ]; then
        rm -f /etc/nginx/sites-enabled/ghostwire /etc/nginx/sites-available/ghostwire
        systemctl is-active --quiet nginx && systemctl reload nginx
    fi
    echo ""
    p_ask "Domain-et ro bezan (meslan: tunnel.mysite.com): "
    read -r DOMAIN
    while [ -z "$DOMAIN" ]; do
        p_err "Domain lazem-e!"
        p_ask "Domain: "
        read -r DOMAIN
    done
    cat > /etc/nginx/sites-available/ghostwire <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}
EOF
    ln -sf /etc/nginx/sites-available/ghostwire /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
    p_ok "Nginx config aval sakhte shod."
    echo ""
    p_ask "TLS certificate ba Let's Encrypt begirim? [y/N]: "
    read -r -n 1 TLS_REPLY
    echo ""
    if [[ "$TLS_REPLY" =~ ^[Yy]$ ]]; then
        certbot --nginx -d "$DOMAIN"
        p_ok "TLS certificate gereft!"
    fi
    local WS_PORT_CURRENT
    WS_PORT_CURRENT=$(grep "listen_port" /etc/ghostwire/server.toml | cut -d'=' -f2 | tr -d ' ')
    WS_PORT_CURRENT="${WS_PORT_CURRENT:-8443}"
    cat > /etc/nginx/sites-available/ghostwire <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    location /ws {
        proxy_pass http://127.0.0.1:${WS_PORT_CURRENT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
        proxy_buffering off;
        proxy_request_buffering off;
        tcp_nodelay on;
    }
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF
    nginx -t && systemctl reload nginx
    p_ok "Nginx config kamel shod baraye: ${DOMAIN}"
    local PANEL_ENABLED_CHECK
    PANEL_ENABLED_CHECK=$(grep "^enabled=true" /etc/ghostwire/server.toml 2>/dev/null | head -1 || true)
    if [ -n "$PANEL_ENABLED_CHECK" ]; then
        echo ""
        p_ask "Baraye panel ham yek domain-e joda mikhai? [y/N]: "
        read -r -n 1 PANEL_DOMAIN_REPLY
        echo ""
        if [[ "$PANEL_DOMAIN_REPLY" =~ ^[Yy]$ ]]; then
            p_ask "Panel domain: "
            read -r PANEL_DOMAIN
            local PANEL_PORT_CURRENT
            PANEL_PORT_CURRENT=$(grep "^port=" /etc/ghostwire/server.toml 2>/dev/null | tail -1 | cut -d'=' -f2 || echo "9090")
            rm -f /etc/nginx/sites-enabled/ghostwire-panel /etc/nginx/sites-available/ghostwire-panel
            cat > /etc/nginx/sites-available/ghostwire-panel <<EOF
server {
    listen 80;
    server_name ${PANEL_DOMAIN};
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
}
EOF
            ln -sf /etc/nginx/sites-available/ghostwire-panel /etc/nginx/sites-enabled/
            nginx -t && systemctl reload nginx
            p_ask "TLS baraye domain-e panel? [y/N]: "
            read -r -n 1 PANEL_TLS
            echo ""
            [[ "$PANEL_TLS" =~ ^[Yy]$ ]] && certbot --nginx -d "$PANEL_DOMAIN"
            cat > /etc/nginx/sites-available/ghostwire-panel <<EOF
server {
    listen 80;
    server_name ${PANEL_DOMAIN};
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
server {
    listen 443 ssl http2;
    server_name ${PANEL_DOMAIN};
    ssl_certificate /etc/letsencrypt/live/${PANEL_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${PANEL_DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    location / {
        proxy_pass http://127.0.0.1:${PANEL_PORT_CURRENT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
            nginx -t && systemctl reload nginx
            p_ok "Panel nginx config tamam shod: https://${PANEL_DOMAIN}"
        fi
    fi
}

install_server() {
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}🇮🇷  Iran Server Mode${NC}"
    echo ""
    p_info "In server darun-e Iran nasb mishe."
    p_info "Vazife: Port-haye local ro listen kone va traffic ro az tunel forward kone."
    p_info "Kharej (client) az birun be in server vasl mishe."
    echo ""
    p_sep
    p_step "Gam 1: Daryaft va Nasb-e Binary (Step 1: Download & Install)"
    download_binary "ghostwire-server"
    p_step "Gam 2: Tanzim-e Config (Step 2: Configure)"
    configure_server
    p_step "Gam 3: Systemd Service (Step 3: Setup Service)"
    p_info "Systemd service ye daemon-e ke GhostWire ro khodkar shoru mikone."
    p_info "Agar server restart she, GhostWire khodesh shoru mishe."
    install_systemd_service "ghostwire-server"
    p_step "Gam 4: Nginx Setup (Step 4: Reverse Proxy)"
    setup_nginx_server
    p_step "Gam 5: Shoru-e Service (Step 5: Start Service)"
    start_service "ghostwire-server"
    p_step "Nasb Tamam Shod! (Installation Complete!) 🎉"
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}✓  GhostWire Server dar Iran nasb shod!${NC}"
    echo ""
    echo -e "  ${BLUE}ℹ${NC}  Config: /etc/ghostwire/server.toml"
    echo -e "  ${BLUE}ℹ${NC}  Log file: /var/log/ghostwire-server.log"
    echo ""
    echo -e "  ${BLUE}${BOLD}Dastorat (Useful Commands):${NC}"
    echo ""
    echo -e "  ${BLUE}sudo systemctl status ghostwire-server${NC}   - Status check"
    echo -e "  ${BLUE}sudo systemctl restart ghostwire-server${NC}  - Restart kone"
    echo -e "  ${BLUE}sudo systemctl stop ghostwire-server${NC}     - Stop kone"
    echo -e "  ${BLUE}sudo journalctl -u ghostwire-server -f${NC}   - Live log"
    echo -e "  ${BLUE}sudo ghostwire-server update${NC}             - Manual update"
    echo ""
    p_warn "Faramosh Nakoni: Token ro ke bala neshon dade shod, save kon!"
    p_warn "Baraye nasb-e client-e kharej, token lazem dari."
    echo ""
    p_sep
    echo ""
    echo -e "  ${BLUE}${BOLD}Gam Baadi (Next Step):${NC}"
    echo -e "  ${BLUE}ℹ${NC}  Boro sar server-e kharej (Netherlands/Germany/etc)"
    echo -e "  ${BLUE}ℹ${NC}  Inja ejra kon:  sudo ./setup.sh"
    echo -e "  ${BLUE}ℹ${NC}  Entekhab kon:   Kharej Client"
    echo -e "  ${BLUE}ℹ${NC}  URL server:     wss://YOUR-IRAN-DOMAIN/ws  (ya direct IP:PORT)"
    echo -e "  ${BLUE}ℹ${NC}  Token:          Hamoon chi ke bala save kardi"
    echo ""
}

configure_client() {
    p_step "Tanzim-ate client (Client configuration)"
    if [ -f /etc/ghostwire/client.toml ]; then
        p_warn "Config ghablan vojod dasht: /etc/ghostwire/client.toml"
        p_warn "Jadid nasazi - haman config ro negah midim."
        return
    fi
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}1. URL-e Server-e Iran${NC}"
    p_info "Inja URL-e server-e Iran ro mide. Chand shakl dare:"
    p_info "  wss://tunnel.mysite.com/ws   (ba nginx + SSL)"
    p_info "  ws://1.2.3.4:8443/ws         (direct, bedun-e SSL)"
    p_info "  https://tunnel.mysite.com/ws (ham kar mikone)"
    echo ""
    local server_url=""
    while true; do
        p_ask "URL-e server-e Iran: "
        read -r server_url
        [ -z "$server_url" ] && { p_err "URL lazem-e!"; continue; }
        [[ "$server_url" =~ ^(wss?|https?):// ]] && break
        p_err "URL bayad ba ws://, wss://, http://, ya https:// shoru she!"
    done
    p_ok "Server URL: ${server_url}"
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}2. Token-e Amniyati${NC}"
    p_info "Hamoon token-i ke dar Iran server nasb kardim."
    p_info "Agar yad dari, az server-e Iran copy kon:"
    p_info "  grep token /etc/ghostwire/server.toml"
    echo ""
    local auth_token=""
    while true; do
        p_ask "Token: "
        read -r auth_token
        [ -z "$auth_token" ] && { p_err "Token lazem-e!"; continue; }
        break
    done
    p_ok "Token: ${auth_token:0:8}... (accepted)"
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}3. Auto-Update${NC}"
    p_info "GhostWire khodesh az GitHub update mishe."
    p_ask "Auto-update faal bashe? [Y/n]: "
    read -r AU
    AU="${AU:-y}"
    local auto_update="true"
    if [[ "$AU" =~ ^[Nn]$ ]]; then
        auto_update="false"
        p_warn "Auto-update: Gheyr-e Faal"
    else
        p_ok "Auto-update: Faal"
    fi
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}Kholaseh (Summary):${NC}"
    p_info "Server URL: ${server_url}"
    p_info "Token: ${auth_token:0:8}..."
    p_info "Auto-update: ${auto_update}"
    echo ""
    p_ask "Confirm? Zakhire beshe? [Y/n]: "
    read -r CONFIRM
    CONFIRM="${CONFIRM:-y}"
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        p_err "Nasb cancel shod."
        exit 1
    fi
    mkdir -p /etc/ghostwire
    cat > /etc/ghostwire/client.toml <<EOF
[server]
protocol="websocket"
url="${server_url}"
token="${auth_token}"
ping_interval=30
ping_timeout=60
ws_send_batch_bytes=65536
auto_update=${auto_update}
update_check_interval=300
update_check_on_startup=true

[reconnect]
initial_delay=1
max_delay=60
multiplier=2

[cloudflare]
enabled=false
ips=[]
host=""
check_interval=300
max_connection_time=1740

[logging]
level="info"
file="/var/log/ghostwire-client.log"
EOF
    p_ok "Config zakhire shod: /etc/ghostwire/client.toml"
}

install_client() {
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}🌍  Kharej Client Mode${NC}"
    echo ""
    p_info "In client BIRUN AZ IRAN nasb mishe."
    p_info "Vazife: Be server-e Iran vasl she, traffic-e Iran ro be internet bar gardoone."
    p_info "Client khodesh vasl mishe - Iran block nemikone chon inbound-e."
    echo ""
    p_sep
    p_step "Gam 1: Daryaft va Nasb-e Binary (Step 1: Download & Install)"
    download_binary "ghostwire-client"
    p_step "Gam 2: Tanzim-e Config (Step 2: Configure)"
    configure_client
    p_step "Gam 3: Systemd Service (Step 3: Setup Service)"
    p_info "Systemd service ye daemon-e ke GhostWire ro khodkar shoru mikone."
    p_info "Agar server restart she, GhostWire khodesh vasl mishe."
    install_systemd_service "ghostwire-client"
    p_step "Gam 4: Shoru-e Service (Step 4: Start Service)"
    start_service "ghostwire-client"
    p_step "Nasb Tamam Shod! (Installation Complete!) 🎉"
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}✓  GhostWire Client dar Kharej nasb shod!${NC}"
    echo ""
    echo -e "  ${GREEN}ℹ${NC}  Config: /etc/ghostwire/client.toml"
    echo -e "  ${GREEN}ℹ${NC}  Log file: /var/log/ghostwire-client.log"
    echo ""
    echo -e "  ${GREEN}${BOLD}Dastorat (Useful Commands):${NC}"
    echo ""
    echo -e "  ${GREEN}sudo systemctl status ghostwire-client${NC}   - Status check"
    echo -e "  ${GREEN}sudo systemctl restart ghostwire-client${NC}  - Restart kone"
    echo -e "  ${GREEN}sudo systemctl stop ghostwire-client${NC}     - Stop kone"
    echo -e "  ${GREEN}sudo journalctl -u ghostwire-client -f${NC}   - Live log"
    echo -e "  ${GREEN}sudo ghostwire-client update${NC}             - Manual update"
    echo ""
    p_sep
    echo ""
    echo -e "  ${GREEN}${BOLD}Test Kon (How to test):${NC}"
    echo -e "  ${GREEN}ℹ${NC}  Boro sar yek mashine darun-e Iran"
    echo -e "  ${GREEN}ℹ${NC}  Ports-haye tanimsaz-shode (masalan 8080, 8443) ro test kon"
    echo -e "  ${GREEN}ℹ${NC}    curl -v http://IRAN_SERVER_IP:8080"
    echo -e "  ${GREEN}ℹ${NC}  Agar tunel kar mikone, traffic ba internet-e kharej javab mide"
    echo ""
    p_warn "Agar Cloudflare dari: dar /etc/ghostwire/client.toml"
    p_warn "  cloudflare enabled=true set kon baraye paydari bishtar"
    echo ""
}

main() {
    p_banner
    p_step "Salam! Khosh Amadid be GhostWire Easy Installer"
    p_info "In script GhostWire ro gam-be-gam baraye to nasb mikone."
    p_info "Kharej = Client (birun az Iran) | Iran = Server (darun-e Iran)"
    echo ""
    p_warn "Hame chiz ba sudo ejra mishe - baraye nasb-e software lazem-e."
    echo ""
    check_prerequisites
    ask_location
    if [ "$INSTALL_MODE" = "IRAN" ]; then
        install_server
    else
        install_client
    fi
    echo ""
    echo -e "  ${GREEN}${BOLD}Kheyr! Movafagh bashi! 🎉${NC}"
    echo ""
}

main
