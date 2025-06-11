#!/bin/bash

set -e

# Update packages and install Amazon Corretto 21 (Java 21)
sudo yum update -y
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-21-amazon-corretto

# Create the minecraft user if not exists
id minecraft &>/dev/null || sudo useradd -m -r -d /opt/minecraft minecraft

# Set up the Minecraft server directory
sudo mkdir -p /opt/minecraft/server
sudo chown minecraft:minecraft /opt/minecraft/server
cd /opt/minecraft/server

# Download Minecraft server JAR
sudo -u minecraft curl -o minecraft_server.1.21.5.jar https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accept the Minecraft EULA
echo "eula=true" | sudo tee /opt/minecraft/server/eula.txt > /dev/null

# Determine Java path
JAVA_PATH=$(command -v java)

# Create systemd service unit
sudo tee /etc/systemd/system/minecraft.service > /dev/null <<EOL
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=1
WorkingDirectory=/opt/minecraft/server
ExecStart=${JAVA_PATH} -Xmx1G -jar minecraft_server.1.21.5.jar nogui
StandardOutput=append:/var/log/minecraft.log
StandardError=append:/var/log/minecraft.err
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Minecraft service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft

# Open Minecraft port (if firewalld is active)
sudo firewall-cmd --permanent --add-port=25565/tcp || true
sudo firewall-cmd --reload || true
