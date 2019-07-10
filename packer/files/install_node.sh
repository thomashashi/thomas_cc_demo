#! /bin/bash

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo 'Waiting for cloud-init to finish...'
  sleep 1
done

# install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sleep 15
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs > /dev/null
sleep 15

# install the listing service app
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/thomashashi/listing-service.git
cd listing-service
npm install
cd ..
sudo chown -R ubuntu:ubuntu /home/ubuntu/src
