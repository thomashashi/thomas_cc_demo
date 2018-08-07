#! /bin/bash

# install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sleep 15
sudo apt-get install -y nodejs
sleep 15

# install the listing service app
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/norhe/listing-service.git
cd listing-service
npm install

# systemd
cat <<EOF | sudo tee /lib/systemd/system/listing.service
[Unit]
Description=server.js - Listing service API
Documentation=https://example.com
After=network.target

[Service]
Environment=LISTING_PORT=8000
Environment=DB_URL=mongodb.service.consul
Environment=DB_PORT=8001
Type=simple
User=ubuntu
ExecStart=/usr/bin/node /home/ubuntu/src/listing-service/server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable listing.service
