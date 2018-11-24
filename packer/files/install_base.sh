#! /bin/bash

echo "Updating and installing required software..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq unzip wget jq python3-pip > /dev/null

cat <<EOF | sudo tee /lib/systemd/system/consul_enable_acl.service
[Unit]
Description = Enable ACL system for consul agent
Requires=consul.service
After=consul.service

[Service]
Type=oneshot
ExecStart=/etc/consul/enable_acl.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl disable consul_enable_acl.service

echo "Adding reinvent user"
sudo adduser --disabled-password --gecos "reInvent User" reinvent
sudo install -d -o reinvent -g reinvent -m 700 /home/reinvent/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3KPO8/w3pGuCGFoE1s8YD9EokD+zk6gDzjXbKQL9Ll AWS re:Invent 2018 Consul Demo reinvent user" | sudo tee /home/reinvent/.ssh/authorized_keys > /dev/null
sudo chown reinvent:reinvent /home/reinvent/.ssh/authorized_keys
sudo chmod 600 /home/reinvent/.ssh/authorized_keys

echo "Finished!"

