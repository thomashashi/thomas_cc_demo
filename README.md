# Consul Connect Demo

This repo demonstrates using Consul Connect.  There are a number of moving parts.  

First, a Consul cluster is deployed.  Then, a set of client nodes are deployed.  All client nodes have Consul running.

There are four pieces of the application.  A mongo database to store records, a set of APIs called Product and Listing, and a web client that renders results.  All pieces communicate with one another using the built in Consul Connect proxies.

Additionally, a single Vault server is also deployed.  That Vault server can be used as the CA for Consul Connect.  This currently requires some manual configuration, however.

## Prerequisites

This example runs in GCP.  One must be able to authenticate and have a project created to house the machines.

It requires Consul be available to create a gossip encryption key.

It requires Terraform and Packer.

## Usage

Clone the repo.  Change directory into the "packer" directory, and inspect build.sh.  That script builds all the required images.

Then you can run build.sh to build the packer images:

```
./build.sh ~/.gcloud/your_env.json your-env us-east1-c
```

Now you can run the terraform to deploy:

```
cd ..
# Ensure you have the proper environment variables set.  Something like:
export GOOGLE_CREDENTIALS="$(< /home/you/.gcloud/your-credentials.json)"
export GOOGLE_PROJECT="your-env"

terraform apply
```

You will need to give things a moment to stabilize after the deployment finishes.  After some period of time you should be able to check the Consul UI in a browser from one of the servers ips like:

```
http://$SERVER_IP:8500
```

Once all the services are healthy you can navigate to the web client addr on port 8080

```
http://$WEB_CLIENT_IP:8080
```

You should see the UI with records from the product and listing APIs.

## Demo

To demonstrate Connect you can simply edit intentions from the UI.  Create intentions that allow traffic from the web_client service to the listing and product APIs.  You can then selectively allow or block traffic, and refresh the client page showing that the individual API results are instantly blocked.

You can also move the CA to the Vault server if you like.  Please note that you must manually move the CA.  You cannot just update the config file and restart Consul:
https://www.consul.io/docs/connect/ca/vault.html

An example command file might be:
```
consul connect ca set-config -config-file ca_config.json
```

... and the contents of ca_config.json may be something like:
```
{    
    "ca_provider" : "vault",
   " ca_config" :  {
        "address" : "http://$VAULT_SERVER:8200",
        "token" : "$APPROPRIATE_TOKEN",
        "root_pki_path" : "connect-root",
        "intermediate_pki_path" : "connect-intermediate"
    }
}
```

If you are in fact just setting this up to demo Connect then you can make your life easier by passing in the root token.  Don't do that in production though!