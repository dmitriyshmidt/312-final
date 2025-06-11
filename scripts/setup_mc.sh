#!/bin/bash

set -e

# Update packages and install Java
sudo yum update -y
sudo yum install -y java-1.8.0-amazon-corretto

# Ensure java is in the expected location
JAVA_PATH=$(readlink -f $(which java))
echo "Java installed at: $JAVA_PATH"

# Create a minecraft user
sudo useradd -m -r -d /opt/minecraft minecraft

# Create server directory
sudo mkdir -p /opt/minecraft/server
sudo chown minecraft:minecraft /opt/minecraft/server
cd /opt/minecraft/server

# Download Minecraft server jar
sudo -u minecraft curl -o minecraft_server.1.21.5.jar https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accept EULA
echo "eula=true" | sudo tee /opt/minecraft/server/eula.txt

# Create a systemd service
JAVA_PATH=$(command -v java)
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

# Enable and start the service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft

# Disable firewalld or open port 25565 (if active)
sudo firewall-cmd --permanent --add-port=25565/tcp || true
sudo firewall-cmd --reload || true

