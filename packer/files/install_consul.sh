#! /bin/bash

echo "Unzipping Consul"
cd /tmp && sudo unzip consul.zip -d /usr/local/bin/

echo "Creating consul user and group"
sudo adduser --no-create-home --disabled-password --gecos "" consul

echo "Creating directories"
sudo mkdir -p /etc/consul/
sudo chown -R consul:consul /etc/consul/
sudo mkdir -p /opt/consul/
sudo chown -R consul:consul /opt/consul/


# systemd
echo "creating systemd unit file"
cat <<EOF | sudo tee /lib/systemd/system/consul.service
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir /etc/consul/ $FLAGS 
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=131072

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0664 /lib/systemd/system/consul*

sudo systemctl daemon-reload
sudo systemctl disable consul.service

echo "Finished!"
