#! /bin/bash

# install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl enable mongod
sudo systemctl start mongod

sleep 10

# seed some initial records
cat <<EOF >> /tmp/m.js
use bbthe90s
db.products.insertMany([ { 'inv_id': 1, 'name':'jncos', 'cost':35.57, 'img':null}, { 'inv_id': 2, 'name':'denim vest', 'cost':22.50, 'img':null}, { 'inv_id': 3, 'name':'pooka shell necklace', 'cost':12.37, 'img':null}, { 'inv_id': 4, 'name':'shiny shirt', 'cost':17.95, 'img':null}])
db.listings.insertMany([ { 'listing_id': 1, 'name':'old pants', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 2, 'name':'denim vest', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 3, 'name':'pooka shell necklace', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 4, 'name':'shiny shirt', 'reserve':35.57, current_bid: 23.43, 'img':null}])
EOF

mongo < /tmp/m.js
