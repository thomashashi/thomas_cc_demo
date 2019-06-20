# Running the Consul Connect Demo

## Overview

This terraform code will spin up a simple three-tier web application that illustrates the differences in tiers using Consul for service discovery only (web_client to listings), and other tiers that use Service Discovery and Consul Connect (web_client to products).

> Previous versions of this demo used seperate environments to demonstrate Service Discovery ("noconnect" mode) and Consul Connect ("connect" mode).  These two environments have been combined into one demo.  The instructions have changed accordingly.

For reference, the three tiers are:

 1. A web frontend `web_client`, written in Python, which calls...
 2. Two internal apis.  Both access data a common MongoDB database
  2a. `listing` service written in Node
  2b. `product` service written in Python
 3. A MongoDB instance

### Architecture Diagrams

from previous connect/non-connect variants:

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
    3. Change `ssh_key_name` to the name of the key identified in "Requirement 4"
    4. Set `top_level_domain` to a TLD in the Route53 Zone set below
    5. Change `route53_zone_id` to the AWS Route53 Zone ID you want to use
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
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
3. save the following text to `prepared.json`
    1. if deploying to one datacenter use:
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
    2. if deploying to two datacenters, use:
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

### Show the webclient UI

- `terraform output webclient-lb`
- Point a web browser at the value returned

### Connect to `webclient` service

- `terraform output webclient_servers`
- `ssh ubuntu@<first ip returned>`
  - Answer `yes` when asked `Are you sure you want to continue connecting (yes/no)?`

- Part 1 - Show differences between Service Discovery & Consul Connect
- `cat /lib/systemd/system/web_client.service`
  - `Environment=LISTING_URI=http://listing.service.consul:8000`
    - tells `web_client` how to talk to the `listing` service (service discovery)
  - `Environment=PRODUCT_URI=http://localhost:10001`
    - Connecting to something on `localhost` **not** connecting across the network

- Part 2 - Network traffic between `web_client` and `listing` services
  - dump all packet data to `listing` service without any headers:
    - `sudo tcpdump -A 'host listing.service.consul and port 8000 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  - Switch to browser and reload the page a few times
  - Return to terminal - point out **packet data traversing the network in plaintext**
  - Hit _Cntl-C_ to exit `tcpdump`
  - Summary: `web_client` is finding `listing` services dynamically, but nothing is protecting their traffic

- Part 3A - Connection Config between `web_client` and `product` services
  - review `web_client` consul config
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
  - The `web_client` service is configured for Consul Connect
    - talks to `product` services via Consul Connect
    - reaches them by connecting to `localhost` on port `10003`
  - Summary: `web_client` is dynamically linking with the `product` services AND  un-encrypted traffic is _only_ traveling to a local system process

- Part 3B - Network traffic between between `web_client` and `product` services
  - Since its connecting though consul connect, we need to determine the actual hostname and port
  - Query Consul DNS for `product` services info with command:
    - `dig +short product.connect.consul srv`
      - returns something like `1 1 20191 ip-10-0-3-63.node.dc1.consul.`
      - The third number (`20191` in example) is _Consul Connect Proxy_ Port for an instance of the `listing` service
      - The fourth item (`ip-10-0-3-63.node.dc1.consul."` in example) is the internal hostname for that Connect proxy
  - Display packet data to `product` service without any headers:
    - Option A - auto-capture hostname & port from `dig` output
      - capture vars:
        -`dig +short product.connect.consul srv > .rec && HN=$(awk 'NR==1{print $4}' .rec | sed s/\.$//) && HP=$(awk 'NR==1{print $3}' .rec)`
      - run dig using captured vars:
        - `sudo tcpdump -A "host $HN and port $HP and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)"`
    - Option B - manually paste hostname & port
      - Replace `<hostname>` and `<port>` with the associated items from last step
      - `sudo tcpdump -A 'host <hostname> and port <port> and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  - Go to the browser window, reload a few times
  - Return to terminal - point out **all the traffic is TLS-encrypted gibberish**
  - Hit _Cntl-C_ to exit `tcpdump`
  - Summary: `web_client` is connecting to `product` services via Consul Connect and all data is automatically TLS encrypted

- End of WebClient
  - `exit` to close the SSH connection

### Connect to `listing` service

- `terraform output listing_api_servers`
- `ssh ubuntu@<first ip returned>`
  - When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter

- **ERROR IN DOCS - LISTING_ADDR = 0.0.0.0 and fails if set to 127.0.0.1**
  - `cat /lib/systemd/system/listing.service`
  - Point out these lines
    ```bash
    Environment=LISTING_PORT=8000
    Environment=LISTING_ADDR=127.0.0.1
    ```
  - This tells the `listing` service to _only_ listen on `localhost` port 8000

- Review `listing` service consul config
  - `cat /etc/consul/listing.hcl`
    - Look at the `connect=` stanza
    - This serves two purposes
      - makes `listing` available over connect at port 8000
      - allows `listing` service to connect to `mongodb` via Connect

### Making the connection

 1. Point out that all you did to change a standard Node application was to configure Consul Connect and  _tell the app to listen only on localhost_
    1. `listing` knows _nothing_ about TLS
    2. `listing` knows _nothing_ about mutual-TLS authentication
    4. `listing` doesn't have to manage certificates, keys, CRLs, CA certs...
    5. `listing` simply sees _simple, unencrypted traffic_ coming to it
 2. Point out that by configuring `listing` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_ **ERROR IN DOCS - localhost doesn't work - see line 209**
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

- get fqdn of Consul LB `terraform output consul-lb`
- Access the Consul UI `http://<consul_server_fqdn>:8500/ui`.

Still on the `listing` server

- Config Consul Connect to deny all traffic by default
  - `consul intention create -deny '*' '*'`
  - Test connection by refreshing web browser
    - Note it cannot reach the APIs
- Allow `web_client` to talk to `listing`
  - `consul intention create -allow 'web_client' 'listing'`
  - Test connection by refreshing web browser
    - Note it can now reach the `listing` API
- Allow `web_client` to talk to `product`
  - `consul intention create -allow 'web_client' 'product'`
  - Test connection by refreshing web browser
    - Note it can now reach the `product` API
- Delete ability of `web_client` to talk to `product`
  - `consul intention delete 'web_client' 'product'`
  - Test connection by refreshing web browser
    - Note `product` API is now unreachable again
- Scalability of Intentions
  - with 6 `web_client` instances, 17 `listing` instances and 23 `product` instances
    - you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define
    - All replaced those with _2_ intention definitions
  - Intentions follow the service
    - If you double the number of backends, you have to add _another_ 240 endpoint combinations
    - With Intentions, you do _nothing_ because intentions follow the service

### Configuration K/V - displayed in webclient UI

- Show K/V items on the web UI (under Configurations) by setting KV on Consul
- On Consul UI, create a KV named `product/` which will make it a directory
  - inside that directory, create a key named `state`
    - in the Consul UI, change the type (lower right corner) to HCL
    - set the value to `production` and hit save
  - Additional K/V's created under `product/` will display in the webclient UI
