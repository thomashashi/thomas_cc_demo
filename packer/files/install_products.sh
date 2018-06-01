#! /bin/bash

# install the requirements
pip3 install flask
pip3 install pymongo

# download the apply
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/norhe/product-service.git

# systemd

cat <<EOF | sudo tee /lib/systemd/system/product.service
[Unit]
Description=product.py - Listing service API
Documentation=https://example.com
After=network.target

[Service]
Environment=DB_ADDR=mongodb.service.consul
Environment=DB_PORT=27017
Environment=DB_USER=mongo
Environment=DB_PW=mongo
Environment=DB_NAME=bbthe90s
Environment=COL_NAME=products
Type=simple
User=ubuntu
ExecStart=/usr/bin/python3 /home/ubuntu/src/product-service/product.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable product.service
