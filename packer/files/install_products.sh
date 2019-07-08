#! /bin/bash

# install the requirements
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cache
pip3 install flask
pip3 install pymongo
pip3 install python-consul

# download the apply
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/robertpeteuil/product-service.git
cd ..
sudo chown -R ubuntu:ubuntu /home/ubuntu/src
