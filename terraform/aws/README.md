# Running the Consul Connect Demo

## Overview

This terraform code will spin up a simple three-tier web application that illustrates the differences in tiers using Consul for service discovery only (web_client to listings), and other tiers that use Service Discovery and Consul Connect (web_client to products).

> Previous versions of this demo used seperate demo environments to demonstrate Service Discovery ("noconnect" mode) and Consul Connect ("connect" mode).  These two environments have been combined into one environment that incorporates one connection via Service Discovery and the others via Consul Connect.  These instructions are specific to this new environment.

For reference, the three tiers are:

 1. A web frontend `web_client`, written in Python, which calls...
 2. Two internal apis.  Both access data a common MongoDB database
  2a. `listing` service written in Node
  2b. `product` service written in Python
 3. A MongoDB instance

### Architecture Diagrams

Diagrams of previous connect/non-connect environments:

- [Architecture diagram for Non-connect version](../../diagrams/Consul-demo-No-connect.png)
- [Architecture diagram for Connect version](../../diagrams/Consul-demo-Connect.png)
- [Architecture diagram for Connect version with port #s](../../diagrams/Consul-demo-Connect2.png)

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

## Demo Script

### Demo Prep

- Connect to webclient server
  - `terraform output webclient_servers`
  - `ssh ubuntu@<first ip returned>`

- Open the webclient web UI in browser
  - `terraform output webclient-lb`
  - Open value returned in a web browser

- Open the Consul web UI in browser
  - get fqdn of Consul LB `terraform output consul-lb`
  - Open value returned in format `http://<consul_server_fqdn>:8500/ui`

### Consul Service Discovery

- We're going to review a service using Consul for Service Discovery
  - use ssh connection to webclient server (from step above)
- Display the **web_client service** definition with command
  - `cat /lib/systemd/system/web_client.service`
- **web_client** service calls two APIs, but for now focus on `listing` which uses Service Discovery
  - Point out line in file:
    - `Environment=LISTING_URI=http://listing.service.consul:8000`
    - tells `web_client` how to talk to the `listing` service
    - this is using service discovery
  - Consul resolves service queried with addresses `http://XYZ.service.consul`
    - ex: `ping product.service.consul`

#### Consul Service Discovery - Network traffic

- Network traffic between `web_client` and `listing` services
  - Dump all network packet data to `listing` service:
    - `sudo tcpdump -A 'host listing.service.consul and port 8000 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  - Switch to browser and reload the page a few times
  - Return to terminal - point out **packet data traversing the network in plaintext**
  - Hit _Cntl-C_ to exit `tcpdump`
- **Summary:** `web_client` is finding `listing` services dynamically, but nothing is protecting their traffic

### Consul Connect

- Next review service using Consul Connect
- Display the **web_client service** definition again
  - `cat /lib/systemd/system/web_client.service`
- **web_client** also calls **product** API, but using with Consul Connect
  - Point out line in file:
    - `Environment=PRODUCT_URI=http://localhost:10001`
    - It's connecting to something on `localhost` **not** connecting across the network
    - this is using Consul Connect

#### Consul Connect - Configuration

- Explain connection between `web_client` and `product` services
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

    - This configures Consul to run a local proxy connecting local port `10001` to `product`
- `web_client.service` talks to `product` on `localhost` on port `10001`
  - Consul proxies localhost:10001 to `product` services AND encrypts the traffix
  - Limits un-encrypted traffic to calls betwen local system processes
- **Summary:** `web_client` is dynamically linking the `product` services AND traffic to the remote service (`product`) is encrypted

#### Consul Connect - Network traffic

- Show network traffic between between `web_client` and `product` services
  - We need to dump all packets to the `product` service, like we did above for the `listing` service
  - Query Consul DNS to get hostname and port of `product` services
    - Show Querying Consul DNS:
      - `dig +short product.connect.consul srv`
    - Query Consul DNS and capture vars for hostname & port:
      -`dig +short product.connect.consul srv > .rec && HN=$(awk 'NR==1{print $4}' .rec | sed s/\.$//) && HP=$(awk 'NR==1{print $3}' .rec)`
    - Dump all network packet data to `product` service (using vars captured above):
      - `sudo tcpdump -A "host $HN and port $HP and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)"`
  - Go to the browser window, reload a few times
  - Return to terminal - point out all the traffic is TLS-encrypted gibberish
  - Hit _Cntl-C_ to exit `tcpdump`
- **Summary:** `web_client` is connecting to `product` services via Consul Connect and **all data is automatically TLS encrypted**

- End of WebClient
  - `exit` to close the SSH connection

### Consul Connect Summary

 1. Point out that to connect `web_client` to to `product` via connect was
    1. Enable Connect
    2. Tell `web_client` that `product` service is reachable on localhost ports
    3. Consul Connect handles balancing traffic between 1, 2, 20, 100 healthy instances
    4. Consul Connect _encrypts_ all network traffic
    5. `web_client` knows _nothing_ about TLS
    6. `web_client` knows _nothing_ about mutual-TLS authentication
    7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
    8. `web_client` simply makes the same _simple, unencrypted requests_ it always has
 2. Point out that by configuring `product` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_
 3. Point out that all you did to change a standard application was to configure Consul Connect and  _tell the app to listen only on localhost_
    1. `product` knows _nothing_ about TLS
    2. `product` knows _nothing_ about mutual-TLS authentication
    3. `product` doesn't have to manage certificates, keys, CRLs, CA certs...
    4. `product` simply sees _simple, unencrypted traffic_ coming to it

### Intentions

- Intentions can be defined via CLI or the Consul Web UI
  - If using the CLI, connect to `product` server

1. Config Consul Connect to deny all traffic by default
    - `consul intention create -deny '*' '*'`
    - It cannot reach the `product` API by refreshing web browser
2. Allow `web_client` to talk to `product`
   - `consul intention create -allow 'web_client' 'product'`
   - **Show it can now reach product API** by refreshing the web browser
3. Delete ability of `web_client` to talk to `product`
   - `consul intention delete 'web_client' 'product'`
   - **Show product` API is unreachable again** by refreshing the web browser
4. Describe "Scalability of Intentions"
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
  - In Consul Web UI select `product/` folder & create a key called `test` and assign it a value
- On webclient UI, point out **Configuration** Section
  - the `product` service reads the Consul K/V store (along with the mongodb records) & returns them to `web_client` where they are displayed

### Multi-Region Demo (Only) - Failover with Prepared Queries

> Webclient service is configured to use a "prepared query" to find the `product` service.
> If every product service in the current DC fails, it looks for the service in other DCs

- Setup
  - Create a `product/` K/V folder on each DC
  - in `product/` create a key called "test" with different values in each DC
- Open `web_client` for DC1
  - point out **Configuration** Section
    - lists **datacenter = dc1** and the value of **test** set for DC1
- Trigger Failover
  - in the the Consul UI in DC1
  - on K/V tab, create a key called `run` in `product/` and set it to `false`
- switch to the services tab of the Consul UI in DC1
  - refresh and show the `product` servers slowly
  - keep refreshing until there is one health check failure for each `product` node in the DC (2 by default)
- switch back to `web_client` for DC1
  - point out **Configuration** Section
    - It's not showing **datacenter = dc2** and the value of **test** set for DC2
    - Consul has automatically used the `product` service in DC2
- (optional) review the Consul configuration that llowed the web client to do this
  - ssh into `web_client` in DC1
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
