#!/bin/bash
set -euo pipefail

### VARIABLES - EDIT THESE ###
AZP_URL="https://dev.azure.com/Isdb-DevOps"           # <-- your Azure DevOps org URL
AZP_POOL="Swift Azure Agent"                            # <-- agent pool name
AZP_AGENT_NAME="$(hostname)"                  # <-- unique agent name
AZP_TOKEN="AWPTloelEZslABErdSsmbayHLQtxGMHG8tql48vHDmQDptUutOtMJQQJ99CDACAAAAAJ3KhnAAASAZDOG8SJG4noeS9mG2QXEJuT7Yfpi2JM0pS0jvL0TPhV70IDsQsJfC8M9QkRJQQJ99BIACAAAAAJ3KhnAAASAZDO3Ppt"           # <-- PAT (Agent Pools (read, manage))

# Optional: where to install
INSTALL_DIR="/opt/cicd-DR-agent/"
WORK_DIR="${INSTALL_DIR}/_work"
USER="cicdagent"

### 1. Create dedicated system user ###
if ! id -u "$USER" >/dev/null 2>&1; then
  echo "[*] Creating system user $USER"
  sudo useradd --system --create-home \
      --home-dir /opt/cicd-DR-agent \
      --shell /usr/sbin/nologin \
      $USER
fi

### 2. Prepare directories ###
echo "[*] Creating install directory: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chown -R $USER:$USER /opt/cicd-agent
sudo chmod 700 /opt/cicd-agent

### 3. Download Azure DevOps agent ###
echo "[*] Downloading agent package version 4.260.0"
cd /tmp
AGENT_VERSION="4.260.0"
PACKAGE="vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz"
DOWNLOAD_URL="https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/${PACKAGE}"

curl -sL "$DOWNLOAD_URL" -o "$PACKAGE"

echo "[*] Extracting agent to $INSTALL_DIR"
sudo tar zxvf "$PACKAGE" -C "$INSTALL_DIR"
sudo chown -R $USER:$USER "$INSTALL_DIR"

### 4. Configure agent ###
echo "[*] Configuring agent"
sudo -u $USER bash -c "
cd $INSTALL_DIR
./config.sh --unattended \
  --url $AZP_URL \
  --auth pat \
  --token $AZP_TOKEN \
  --pool $AZP_POOL \
  --agent $AZP_AGENT_NAME \
  --work $WORK_DIR \
  --acceptTeeEula
"

### 5. Create systemd service ###
echo "[*] Installing systemd service"
sudo bash -c "cat > /etc/systemd/system/cicd-agent@.service" <<EOF
[Unit]
Description=IsDB Azure DevOps Agent %i
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=/opt/cicd-agent/%i
ExecStart=/opt/cicd-agent/%i/run.sh
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ReadWritePaths=/opt/cicd-agent/%i
LockPersonality=true
MemoryDenyWriteExecute=true

[Install]
WantedBy=multi-user.target
EOF

### 6. Enable & start service ###
echo "[*] Enabling and starting agent service"
sudo systemctl daemon-reexec
sudo systemctl enable cicd-agent@${AZP_AGENT_NAME}
sudo systemctl start cicd-agent@${AZP_AGENT_NAME}

echo "[✔] Azure DevOps agent $AZP_AGENT_NAME installed and running."
