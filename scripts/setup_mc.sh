#!/bin/bash

# Update packages and install Java
sudo yum update -y
sudo amazon-linux-extras enable corretto8
sudo yum install -y java-1.8.0-amazon-corretto

# Create a minecraft user
sudo useradd -m -r -d /opt/minecraft minecraft

# Create server directory
sudo mkdir -p /opt/minecraft/server
sudo chown minecraft:minecraft /opt/minecraft/server
cd /opt/minecraft/server

# Download Minecraft server jar
sudo -u minecraft curl -o server.jar https://launcher.mojang.com/v1/objects/3e7fbe9c404c4fa2dc6fba1c6fd8e0338c388c89/server.jar

# Accept EULA
echo "eula=true" | sudo tee /opt/minecraft/server/eula.txt

# Create a systemd service
sudo tee /etc/systemd/system/minecraft.service > /dev/null <<EOL
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=1
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx1G -jar server.jar nogui
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
sudo systemctl stop firewalld || true
sudo systemctl disable firewalld || true
