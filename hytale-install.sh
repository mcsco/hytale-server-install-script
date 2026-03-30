#!/usr/bin/env bash
set -euo pipefail

# Script Variables
INSTALL_DIR="/opt/hytale-server"
RUN_USER="${SUDO_USER:-$USER}"
RUN_GROUP="$RUN_USER"
WORK_DIR="/tmp/hytale-install"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Welcome
echo -e ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD}      Hytale Server Installation Script     ${NC}"
echo -e "${GREEN}${BOLD}         Created by: Michael (mcsco)        ${NC}"
echo -e "${GREEN}${BOLD}                 Version: 6                 ${NC}"
echo -e "${GREEN}${BOLD}              Updated: 2026-03-29           ${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e ""

# Post Debian 13 Install
sudo apt update && sudo apt dist-upgrade -y

# Install Requirements for Hytale
sudo apt install -y wget apt-transport-https gpg ufw zip unzip ca-certificates tmux

# Checking that dependecies are installed
command -v sudo >/dev/null 2>&1 || { echo "sudo is required"; exit 1; }
command -v wget >/dev/null 2>&1 || { echo "wget is required"; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "unzip is required"; exit 1; }
command -v tmux >/dev/null 2>&1 || { echo "tmux is required"; exit 1; }

# Creating Hytale Directory
sudo mkdir -vp $INSTALL_DIR
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Changing Hytale Directory Owner
sudo chown -R "$RUN_USER:$RUN_GROUP" "$INSTALL_DIR"

# Installiong Java 25 from Adoptium
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install temurin-25-jdk -y

# Checking if Java installed correctly
command -v java >/dev/null 2>&1 || { echo "java is not installed"; exit 1; }

# Print Java version
echo -e "${CYAN}Java version:${NC}"
java --version

# Hytale Installation Steps
wget -O hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip
unzip -o hytale-downloader.zip
chmod +x hytale-downloader-linux-amd64
./hytale-downloader-linux-amd64 -download-path $INSTALL_DIR/server.zip
unzip $INSTALL_DIR/server.zip -d $INSTALL_DIR
rm $INSTALL_DIR/server.zip

# Hytale file checks
if [[ ! -f "$INSTALL_DIR/Server/HytaleServer.jar" ]]; then
  echo "Error: HytaleServer.jar not found at $INSTALL_DIR/Server/HytaleServer.jar" >&2
  exit 1
fi

if [[ ! -f "$INSTALL_DIR/Assets.zip" ]]; then
  echo "Error: Assets.zip not found at $INSTALL_DIR/Assets.zip" >&2
  exit 1
fi

# Writing Hytale start script
#cat > "$INSTALL_DIR/start-hytale.sh" <<EOF
##!/usr/bin/env bash
#set -euo pipefail
#cd "$INSTALL_DIR"
#exec java -XX:AOTCache=$INSTALL_DIR/Server/HytaleServer.aot -jar $INSTALL_DIR/Server/HytaleServer.jar --assets $INSTALL_DIR/Assets.zip
#EOF

# Creating jvm.options with custom jvm options
cat > "$INSTALL_DIR/jvm.options" <<EOF
-Xms4G
-Xmx8G
-XX:+UseG1GC
-XX:AOTCache=Server/HytaleServer.aot
EOF

# Enabling script execution permission
#chmod +x $INSTALL_DIR/start-hytale.sh

# Enabling execution permission official Hytal Start.sh script
chmod +x $INSTALL_DIR/start.sh

# Checking if start script was created before enabling hytale service
#if [[ ! -x "$INSTALL_DIR/start-hytale.sh" ]]; then
#  echo "Error: start script is missing or not executable" >&2
#  exit 1
#fi

# Writing Hytale Systemd Service
sudo tee /etc/systemd/system/hytale.service > /dev/null <<EOF
[Unit]
Description=Hytale Server (tmux-managed)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=$RUN_USER
Group=$RUN_GROUP
WorkingDirectory=$INSTALL_DIR

ExecStart=/usr/bin/tmux new-session -d -s hytale './start.sh'
ExecStop=/usr/bin/tmux send-keys -t hytale 'stop' C-m
ExecStop=/bin/sleep 10
ExecStopPost=/usr/bin/tmux kill-session -t hytale

TimeoutStartSec=30
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF

# Enabling Hytale Service
sudo systemctl daemon-reload
sudo systemctl enable --now hytale.service

# Basic Server security with UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw logging on
sudo ufw allow 5520/udp
sudo ufw allow OpenSSH
sudo ufw --force enable

# Show the service status automatically
sudo systemctl --no-pager status hytale

# Clean up temporary working directory
rm -rf "$WORK_DIR"

# First boot and authentication steps for your Hytale Server
echo -e ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD}      Hytale Server Installation Complete     ${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e ""

echo -e "${CYAN}${BOLD}Console Access:${NC}"
echo -e "  ${YELLOW}tmux attach -t hytale${NC}"

echo -e ""
echo -e "${CYAN}${BOLD}First-time Authentication:${NC}"
echo -e "  ${YELLOW}/auth login device${NC}"
echo -e "  ${YELLOW}/auth persistence Encrypted${NC}"

echo -e ""
echo -e "${CYAN}${BOLD}Detach from console:${NC}"
echo -e "  ${YELLOW}Ctrl + b then d${NC}"

echo -e ""
echo -e "${CYAN}${BOLD}Systemd Service Commands:${NC}"
echo -e "  ${YELLOW}sudo systemctl status hytale${NC}"
echo -e "  ${YELLOW}sudo systemctl restart hytale${NC}"
echo -e "  ${YELLOW}sudo systemctl stop hytale${NC}"

echo -e ""
echo -e "${GREEN}Server files located at:${NC} ${BLUE}$INSTALL_DIR${NC}"
echo -e ""