#! /bin/bash

set -e

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo 'Waiting for cloud-init to finish...'
  sleep 1
done

echo "Updating and installing required software..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade -y > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq unzip wget jq python3-pip > /dev/null

# echo "Adding reinvent user"
# sudo adduser --disabled-password --gecos "reInvent User" reinvent
# sudo install -d -o reinvent -g reinvent -m 700 /home/reinvent/.ssh
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3KPO8/w3pGuCGFoE1s8YD9EokD+zk6gDzjXbKQL9Ll AWS re:Invent 2018 Consul Demo reinvent user" | sudo tee /home/reinvent/.ssh/authorized_keys > /dev/null
# sudo chown reinvent:reinvent /home/reinvent/.ssh/authorized_keys
# sudo chmod 600 /home/reinvent/.ssh/authorized_keys

echo "Package update & install finished!"

