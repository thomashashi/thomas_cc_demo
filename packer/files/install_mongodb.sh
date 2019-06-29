#! /bin/bash

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo 'Waiting for cloud-init to finish...'
  sleep 1
done

# install mongodb
echo "### apt-key adv"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sleep 5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sleep 5

echo "### apt-get update"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null
sleep 5
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mongodb-org > /dev/null
sleep 5

sudo systemctl enable mongod
sudo systemctl start mongod

sleep 10

# seed some initial records
cat <<EOF >> /tmp/m.js
use bbthe90s
db.products.insertMany([ { 'inv_id': 1, 'name':'Koosh Ball 12 Pack', 'cost':35.57, 'img':null}, { 'inv_id': 2, 'name':'Slap Bracelets 5 Pack', 'cost':22.50, 'img':null}, { 'inv_id': 3, 'name':'Tamagotchi', 'cost':12.37, 'img':null}, { 'inv_id': 4, 'name':'Swatch - Blue', 'cost':17.95, 'img':null}])
db.listings.insertMany([ { 'listing_id': 1, 'name':'100 Floppy Disks', 'reserve':12.95, current_bid: 3.43, 'img':null}, { 'listing_id': 2, 'name':'Multicolor Pen 4 Pack', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 3, 'name':'Garden Gnome', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 4, 'name':'Magic Eye Poster', 'reserve':35.57, current_bid: 23.43, 'img':null}])
EOF

mongo < /tmp/m.js
