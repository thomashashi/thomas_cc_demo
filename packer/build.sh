#! /bin/bash

## Usage:
## ./build.sh ~/.gcloud/default-ehron-env.json my-project us-east1-c

CREDS=$1
PROJ=$2
REGION=$3

# we will use Consul to generate the gossip key.  This has to be shared across datacenters.
echo "Creating gossip encryption key..."
if ! [ -x "$(command -v consul)" ]; then
  echo 'Error: consul is not installed.' >&2
  exit 1
fi

# we need somewhere to put it
if ! [ -d ./files ]
then
    echo "Error: must be able to access ./files to continue.  Please run from the ./packer directory."
    exit 1
fi

echo "encrypt = \"$(consul keygen)\"" > ./files/encrypt.hcl

echo "Building base image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=server \
 packer build -force consul_base.json &


echo "Waiting on base client image..."
wait

echo "Building server image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=server \
 packer build -force server.json &

echo "Building client image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
 packer build -force client_base.json & 

echo "Waiting on server and client bases..."
wait

echo "Building Vault server image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
  GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
  packer build -force vault_server.json &

echo "Building node.js image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
  GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
  packer build -force client_listing.json &

echo "Building flask image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
  GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
  packer build -force client_product.json &

echo "Building mongodb image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
  GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
  packer build -force client_mongodb.json &

echo "Building web client image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
  GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
  packer build -force client_webclient.json &

echo 'Waiting for completion'
wait

echo 'Complete!'