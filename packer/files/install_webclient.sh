#! /bin/bash

# install the requirements
pip3 install flask
pip3 install pymongo

# download the apply
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/norhe/simple-client.git

# systemd

cat <<EOF | sudo tee /lib/systemd/system/web_client.service
[Unit]
Description=client.py - Client service API
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/bin/python3 /home/ubuntu/src/simple-client/client.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable web_client.service
