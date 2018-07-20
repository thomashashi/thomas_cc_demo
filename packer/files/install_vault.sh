#! /bin/bash

echo "Unzipping Vault"
cd /tmp && sudo unzip vault.zip -d /usr/local/bin/

echo "Creating Vault user and group"
sudo adduser --no-create-home --disabled-password --gecos "" vault

echo "Creating directories"
sudo mkdir -p /etc/vault/
sudo chown -R vault:vault /etc/vault/

# systemd
echo "creating systemd unit file"
cat <<EOF | sudo tee /lib/systemd/system/vault.service
[Unit]
Description=Vault Agent
Requires=consul-online.target
After=consul-online.target

[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config /etc/vault/
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/usr/local/bin/vault operator step-down
KillSignal=SIGTERM
User=vault
Group=vault

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | sudo tee /lib/systemd/system/consul-online.target
[Unit]
Description=Consul Online
RefuseManualStart=true
EOF

cat <<EOF | sudo tee /lib/systemd/system/consul-online.service
[Unit]
Description=Consul Online
Requires=consul.service
After=consul.service

[Service]
Type=oneshot
ExecStart=/usr/bin/consul-online.sh
User=consul
Group=consul

[Install]
WantedBy=consul-online.target multi-user.target
EOF

echo "Creating wait for consul script.."
cat <<EOF | sudo tee /usr/bin/consul-online.sh
# waitForConsulToBeAvailable loops until the local Consul agent returns a 200
# response at the /v1/operator/raft/configuration endpoint.
#
# Parameters:
#     None
function waitForConsulToBeAvailable() {
  local consul_addr=$1
  local consul_leader_http_code

  consul_leader_http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/operator/raft/configuration") || consul_leader_http_code=""

  while [ "x${consul_leader_http_code}" != "x200" ] ; do
    echo "Waiting for Consul to get a leader..."
    sleep 5
    consul_leader_http_code=$(curl --silent --output /dev/null --write-out "%{http_code}" "${consul_addr}/v1/operator/raft/configuration") || consul_leader_http_code=""
  done
}

waitForConsulToBeAvailable "${CONSUL_ADDRESS}"
EOF

sudo chmod 0664 /lib/systemd/system/{vault*,consul*}
sudo chmod 0755 /usr/bin/consul-online.sh

sudo systemctl enable vault.service

echo "VAULT_ADDR=http://127.0.0.1:8200" | sudo tee -a /etc/environment

echo "Finished!"
