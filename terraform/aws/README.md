# Running the Consul Connect Demo

## Overview

This terraform code will spin up a simple three-tier web application that illustrates the differences in tiers using Consul for service discovery only (web_client to listings), and other tiers that use Service Discovery and Consul Connect (web_client to products).

> Previous versions of this demo used seperate demo environments to demonstrate Service Discovery ("noconnect" mode) and Consul Connect ("connect" mode).  These two environments have been combined into one "hybrid" demo that is deployed when mode is set to "connect".  These instructions are for the new hybrid demo.

For reference, the three tiers are:

 1. A web frontend `web_client`, written in Python, which calls...
 2. Two internal apis.  Both access data a common MongoDB database
  2a. `listing` service written in Node
  2b. `product` service written in Python
 3. A MongoDB instance

### Architecture Diagrams

Diagrams of previous connect/non-connect environments:

- [Architecture diagram for Non-connect version](../../diagrams/Consul-demo-No-connect.png).
- [Architecture diagram for Connect version](../../diagrams/Consul-demo-Connect.png)
- [Architecture diagram for Connect version with port #s](../../diagrams/Consul-demo-Connect2.png).

### Images

The code which built all of the images is in the `packer` directory located at the top level of this repo. While you shouldn't have to build the images which are used in this demo, the Packer code is there to enable you to do so, and also to allow you to see how the application configuration changes as you move your infrastructure to Consul Connect.

## Requirements

You will need:

 1. A machine with git and ssh installed
 2. The appropriate [Terraform binary](https://www.terraform.io/downloads.html) for your system
 3. An AWS account with credentials which allow you to deploy infrastructure
 4. An already-existing [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
    - *NOTE*: if the EC2 Key Pair you specify is not your default ssh key, you will need to use `ssh -i /path/to/private_key` instead
      of `ssh` in the commands below

### Terminal Setup

 1. Open two distinct terminal windows
 2. In both of them, run the commands:

    ```bash
    export AWS_ACCESS_KEY_ID="<your access key ID>"
    export AWS_SECRET_ACCESS_KEY="<your secret key>"
    export AWS_DEFAULT_REGION="us-east-1"
    ```

    Replace `<your access key ID>` with your AWS Access Key ID and `<your secret key>` with your AWS Secret Access Key (see [Access Keys (Access Key ID and Secret Access Key)](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for more help).

### Check out code

 1. `git clone https://github.com/thomashashi/thomas_cc_demo.git cc-connect`

## Deployment

 1. `cd cc-connect/terraform/aws/`
 2. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
 3. Edit the `terraform.auto.tfvars` file:
    1. Change the `project_name` to something which is: all lowercase letters/numbers/dashes and unique to you
    2. In the `hashi_tags` line change `owner` to be your email address.
       - The combination of `project_name` and `owner` **must be unique within your AWS organization** --- they are used to set the Consul cluster membership when those instances start up
    3. Set `ssh_key_name` to the name of the key identified in "Requirement 4"
    4. Set `top_level_domain` to a TLD in the Route53 Zone set below
    5. Set `route53_zone_id` to the AWS Route53 Zone ID you want to use
    6. Set `consul_dc` to `dc1` if this is the first cluster
       - if setting up a 2nd cluster in another region, set to `dc2`
    7. Set `consul_acl_dc` to `dc1` if this is the 1st or alternate cluster
    8. Set `mode` to `connect`
    9. Set `consul_lic` to your Consul Enterprise License string

 4. Save your changes to the `terraform.auto.tfvars` file
 5. Run `terraform init`
 6. When you see "Terraform has been successfully initialized!" ...
 7. Run `terraform plan`
 8. Verify the plan output is as expected
 9. Run `terraform apply` and answer `yes` when prompted

This will take a couple minutes to run. Once the command prompt returns, wait a couple minutes and the demo will be ready.

### Configure Consul for Prepared Query on Products

After the servers are deployed but *before starting a demo*:

1. `terraform output consul_servers`
2. `ssh ubuntu@<first ip returned>`
3. save the following text to `prepared.json`

    if deploying to one datacenter use:

    ```json
    {
    "Name": "product",
    "Service": {
        "Service": "product",
        "Failover": {
        "Datacenters": ["dc1"]
        },
        "OnlyPassing": true,
        "Connect": true
    }
    }
    ```

    if deploying to two datacenters, use:

    ```json
    {
    "Name": "product",
    "Service": {
        "Service": "product",
        "Failover": {
        "Datacenters": ["dc1", "dc2"]
        },
        "OnlyPassing": true,
        "Connect": true
    }
    }
    ```

4. Run to following command to save the prepared query to consul:

    ```bash
    curl \
        --request POST \
        --data @prepared.json \
        http://127.0.0.1:8500/v1/query
    ```

## Demo Script

### Open the web UIs

- Open the demo webclient UI
  - `terraform output webclient-lb`
  - Open value returned in a web browser

- Open the Consul UI
  - get fqdn of Consul LB `terraform output consul-lb`
  - open value returned in format `http://<consul_server_fqdn>:8500/ui`

### "Webclient" Service using Service Discovery and Consul Connect

#### Describe Service Definition

> Overview: webclient service calls two APIs (one via discovery, one via connect)

- Connect to webclient server
  - `terraform output webclient_servers`
  - `ssh ubuntu@<first ip returned>`
- `cat /lib/systemd/system/web_client.service`
  - Service calls two APIs, one via `LISTING_URI`, and other via `PRODUCT_URI`
  - `Environment=LISTING_URI=http://listing.service.consul:8000`
    - tells `web_client` how to talk to the `listing` service
    - this is using service discovery
  - `Environment=PRODUCT_URI=http://localhost:10001`
    - Connect to something on `localhost` **not** connecting across the network
    - this is using Consul Connect

#### Show network traffic for service using service discovery only

- Network traffic between `web_client` and `listing` services
  - dump all packet data to `listing` service:
    - `sudo tcpdump -A 'host listing.service.consul and port 8000 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  - Switch to browser and reload the page a few times
  - Return to terminal - point out **packet data traversing the network in plaintext**
  - Hit _Cntl-C_ to exit `tcpdump`
  - **Summary:** `web_client` is finding `listing` services dynamically, but nothing is protecting their traffic

#### Describe Consul Connect Config

- Show connection config between `web_client` and `product` services
  - describe `web_client` consul config
    - `cat /etc/consul/web_client.hcl`
    - Point out this stanza:

      ```js
      connect {
        sidecar_service = {
          proxy = {
            upstreams = [
              {
                destination_name = "product"
                local_bind_port = 10001
                destination_type = "prepared_query"
              }
            ]
          }
        }
      }
      ```

  - The `web_client` service talks to `product` services via Consul Connect
    - reaches it by connecting to `localhost` on port `10001`
  - **Summary:** `web_client` is dynamically linking with the `product` services AND  un-encrypted traffic is _only_ traveling to a local system process

#### Show network traffic for service using Consul Connect

- Show network traffic between between `web_client` and `product` services
  - We need to dump all packets to the `product` service, like we did above for the `listing` service
  - Query Consul DNS to get hostname and port of `product` services
    - Show Querying Consul DNS \:
      - `dig +short product.connect.consul srv`
    - Run modified command to capture the hostname & port as vars:
      -`dig +short product.connect.consul srv > .rec && HN=$(awk 'NR==1{print $4}' .rec | sed s/\.$//) && HP=$(awk 'NR==1{print $3}' .rec)`
    - dump all packet data to `product` service (using vars captured above):
      - `sudo tcpdump -A "host $HN and port $HP and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)"`
  - Go to the browser window, reload a few times
  - Return to terminal - point out **all the traffic is TLS-encrypted gibberish**
  - Hit _Cntl-C_ to exit `tcpdump`
  - **Summary:** `web_client` is connecting to `product` services via Consul Connect and all data is automatically TLS encrypted

- End of WebClient
  - `exit` to close the SSH connection

### "Product" Service using Consul Connect

- Connect to product server
  - `terraform output product_api_servers`
  - `ssh ubuntu@<first ip returned>`
- Describe Service Definition
  - `cat /lib/systemd/system/product.service`
  - Point out these lines

    ```ini
    Environment=PRODUCT_PORT=5000
    Environment=PRODUCT_ADDR=127.0.0.1
    ```

  - This tells the `product` service to _only_ listen on `localhost` port 5000

- Review consul config for `product` service
  - `cat /etc/consul/product.hcl`
    - Look at the `connect=` stanza
    - This serves two purposes
      - makes `product` available over connect at port 5000
      - allows `product` service to connect to `mongodb` via Connect

### Consul Connect Summary

 1. Point out that all you did to change a standard application was to configure Consul Connect and  _tell the app to listen only on localhost_
    1. `product` knows _nothing_ about TLS
    2. `product` knows _nothing_ about mutual-TLS authentication
    3. `product` doesn't have to manage certificates, keys, CRLs, CA certs...
    4. `product` simply sees _simple, unencrypted traffic_ coming to it
 2. Point out that by configuring `product` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_
 3. Point out that to connect `web_client` to its backend services, all you had to do was
    1. Enable Connect
    2. Tell `web_client` that its upstream services are reachable on localhost ports
    3. Consul Connect handles balancing traffic between 1, 2, 20, 100 healthy instances
    4. Consul Connect _encrypts_ all network traffic
    5. `web_client` knows _nothing_ about TLS
    6. `web_client` knows _nothing_ about mutual-TLS authentication
    7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
    8. `web_client` simply makes the same _simple, unencrypted requests_ it always has

### Intentions

- Intentions can be defined via CLI or the Consul Web UI
  - If using the CLI, connect to `product` server

1. Config Consul Connect to deny all traffic by default
    - `consul intention create -deny '*' '*'`
    - **Show it cannot reach the APIs** by refreshing web browser
2. Allow `web_client` to talk to `listing`
    - `consul intention create -allow 'web_client' 'listing'`
    - **Show it can now reach the `listing` API** by refreshing the web browser
3. Allow `web_client` to talk to `product`
   - `consul intention create -allow 'web_client' 'product'`
   - **Show it can now reach the `product` API** by refreshing the web browser
4. Delete ability of `web_client` to talk to `product`
   - `consul intention delete 'web_client' 'product'`
   - **Show product` API is unreachable again** by refreshing the web browser
5. Describe "Scalability of Intentions"
   - If you have 6 `web_client` instances, 17 `listing` instances and 23 `product` instances
     - you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define
     - Those can be replaced with just _2_ intention definitions
   - Intentions follow the service
     - If you double the number of backends, you have to add _another_ 240 endpoint combinations
     - With Intentions, you do _nothing_ because intentions follow the service

### Configuration K/V - displayed on webclient UI (under Configuration)

- Populate K/V items on the webclient UI by adding KV entries in Consul
- On Consul Web UI, create entry `product/` and save
  - Any K/V's created under `product/` will display in the webclient UI
  - In Consul Web UI select `product/`, hit create then specify key & value
    - turn off `code` option or change type to HCL (lower right corner)
