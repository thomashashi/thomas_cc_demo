#! /bin/bash

## Usage:
## ./build.sh ~/.gcloud/default-ehron-env.json my-project us-east1-c

CREDS=$1
PROJ=$2
REGION=$3

echo "Building server image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=server \
 packer build -force server.json &

echo "Building client image..."
GCP_ACCOUNT_FILE_JSON=$CREDS GCP_PROJECT_ID=$PROJ \
 GCP_ZONE=$REGION DC_NAME=east NODE_TYPE=client \
 packer build -force client_base.json &

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