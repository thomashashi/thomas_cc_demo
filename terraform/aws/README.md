# Running the Consul Connect Demo

## Background

This terraform code will spin up a simple three-tier web application in one
of two modes: with Consul but _without_ Consul Connect, and one with Consul
and _with_ Consul Connect. It's designed to show how an organization already
using Consul for service discovery might move their infrastructure to
using Consul Connect.

For reference, the three tiers are:

 1. A web frontend `web_client`, written in Python, which calls...
 2. Two internal apis (a `listing` service written in Node, and a `product` service written in Python), both of which store data in ...
 3. A MongoDB instance

In the "non-Connect" version of the demo, services find each other using the [Service Discovery](https://www.consul.io/discovery.html) mechanism in Consul. In the "Connect" version of the demo, we introduce [Service Segmentation](https://www.consul.io/segmentation.html).

The code which built all of the images is in the `packer` directory located at the top level of this repo. While you shouldn't have to build the images which are used in this demo, the Packer code is there to enable you to do so, and also to allow you to see how the application configuration changes as you move your infrastructure to Consul Connect.


## Requirements

You will need:
 1. A machine with git and ssh installed
 2. The appropriate [Terraform binary](https://www.terraform.io/downloads.html) for your system
 3. An AWS account with credentials which allow you to deploy infrastructure
 4. An already-existing [Amazon EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

## Preparation

It's recommended that when you demo that you make two copies of the repo, configure one for non-Connect and one for Connect, and provision them simultaneously. It takes a handful of minutes after the Terraform deploy is done for everything in the environment to be up and running, and until that point you'll see the `web_client` complain that it can't reach one or both of the backend services randomly. Having both up and running will allow you to switch between environments a-la "and let's pull a pre-made one out of the oven!"

### Terminal Setup

 1. Open two distinct terminal windows
 2. In both of them, run the commands:
    ```
    export AWS_ACCESS_KEY_ID="<your access key ID>"
    export AWS_SECRET_ACCESS_KEY="<your secret key>"
    export AWS_DEFAULT_REGION="us-east-1"
    ```
    Replace `<your access key ID>` with your AWS Access Key ID and `<your secret key>` with your AWS Secret Access Key (see [Access Keys (Access Key ID and Secret Access Key)](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) for more help). *NOTE*: Currently, the Packer-built AMIs are only in `us-east-1`.

In the rest of this demo we will call these windows respectively the _NO-CONNECT_ and the _CONNECT_ windows. 

### Check out code

 1. In the _NO-CONNECT_ window run: `git clone https://github.com/thomashashi/thomas_cc_demo.git no-connect` --- this checks out the code in a directory we will use for the _non-Connect_ version of the demo
 2. In the _CONNECT_ window run: `git clone https://github.com/thomashashi/thomas_cc_demo.git connect` --- this checks out the code in a directory we will use for the _Connect_ version of the demo

## Deployment

### Deploy the NO-CONNECT Version

In the _NO-CONNECT_ window:

 1. `cd no-connect/terraform/aws/`
 2. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
 3. Edit the `terraform.auto.tfvars` file:
    1. Change the `project_name` to something which is 1) only all lowercase letters, numbers and dashes; 2) is unique to you; 3) and ends in `-noconnect`
    2. In the `hashi_tags` line change `owner` to be your email address.
    3. Change `ssh_key_name` to the name of the key identified in "Requirement 4"

    The combination of `project_name` and `owner` **must be unique within your AWS organization** --- they are used to set the Consul cluster membership when those instances start up
 4. Save your changes to the `terraform.auto.tfvars` file
 5. `terraform init`
 6. When you see "Terraform has been successfully initialized!" ...
 7. Run `terraform plan -out tf.plan`
 8. When you see
    ```
    This plan was saved to: tf.plan

    To perform exactly these actions, run the following command to apply:
        terraform apply "tf.plan"
    ```
    ...
 9. Run `terraform apply tf.plan`

This will take a couple minutes to run. Once the command prompt returns, wait a couple minutes and the demo will be ready.

### Deploy the CONNECT Version

In the _CONNECT_ window:

 1. `cd no-connect/terraform/aws/`
 2. `cp terraform.auto.tfvars.example terraform.auto.tfvars`
 3. Edit the `terraform.auto.tfvars` file:
    1. Change the `project_name` to something which is 1) only all lowercase letters, numbers and dashes; 2) is unique to you; 3) and ends in `-connect`
    2. In the `hashi_tags` line change `owner` to be your email address.
    3. Change `ssh_key_name` to the name of the key identified in "Requirement 4"
    4. Change `mode` to `connect`

    The combination of `project_name` and `owner` **must be unique within your AWS organization** --- they are used to set the Consul cluster membership when those instances start up
 4. Save your changes to the `terraform.auto.tfvars` file
 5. `terraform init`
 6. When you see "Terraform has been successfully initialized!" ...
 7. Run `terraform plan -out tf.plan`
 8. When you see
    ```
    This plan was saved to: tf.plan

    To perform exactly these actions, run the following command to apply:
        terraform apply "tf.plan"
    ```
    ...
 9. Run `terraform apply tf.plan`

This will take a couple minutes to run. Once the command prompt returns, wait a couple minutes and the demo will be ready.

## Show no-Connect version

Switch to the _NO-CONNECT_ window

### Show the web frontend

 1. `terraform output webclient-lb`
 2. Point a web browser at the value returned

### Connect to the web frontend

 1. `terraform output webclient_servers`
 2. `ssh ubuntu@<first ip returned>`
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
 3. `cat /lib/systemd/system/web_client.service`
    1. The line `Environment=LISTING_URI=http://listing.service.consul:8000` tells `web_client` how to talk to the `listing` service
    2. The line `Environment=PRODUCT_URI=http://product.service.consul:5000` tells `web_client` how to talk to the `product` service
    3. Note how both are using Consul for service discovery
 4. `sudo tcpdump -A 'host listing.service.consul and port 8000 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
 5. Switch to the web browser and reload the page a few times
 6. Return to the terminal and look at the data going back and forth across the network. See how it's in plaintext.
 7. Hit _Cntl-C_ to exit tcpdump
 8. Re-iterate that while services are finding each other dynamically, nothing is protecting their traffic
 9. `cat /etc/consul/web_client.hcl` --- show a routine Consul service definition file, there's some health checks, but very routine

## Introduce Connect Version

Switch to _CONNECT_ window

### Show the web frontend

 1. `terraform output webclient-lb`
 2. Point a web browser at the value returned

### Connect to the web frontend

 1. `terraform output webclient_servers`
 2. `ssh ubuntu@<first ip returned>`
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
 3. `cat /lib/systemd/system/web_client.service`
    1. Point out how the `Environment=LISTING_URI` and `Environment=PRODUCT_URI` have changed to talk to
       something on `localhost` --- they're not connecting across the network
 4. `cat /etc/consul/web_client.hcl`
    1. Look at this stanza:
    ```
	connect = {
 	 proxy = {
	  config = {
	    upstreams = [
	      { 
		destination_name = "listing",
		local_bind_port = 10002
	      },
	      { 
		destination_name = "product"
		local_bind_port  = 10001
	      }
	    ]
	  }
	}
      }
     ```
     2. Point out that this means that the `web_client` service is telling Consul Connect that
        1. It wants to talk to the `listing` service via Consul Connect, and that to reach it 
	   it will connect to `localhost` on port `10002`
	2. It wants to talk to the `product` service via Consul Connect, and that to reach it 
	   it will connect to `localhost` on port `10003`
     3. Point out that with this, you have made a link between `web_client` and the `listing` and
        `product` services, and that now the un-encrypted traffic _only goes to a process running
	on the local system_
 5. `dig +short listing.connect.consul srv` --- This will spit out some lines like
    `1 1 20191 ip-172-31-63-3.node.east.consul.`
     1. The third number (`20191` in this case) is the port for the _Consul Connect Proxy_ for an instance of the `listing` service
     2. The hostname (`ip-172-31-63-3.node.east.consul.`) is the internal hostname for that Connect proxy 
 6. `sudo tcpdump -A 'host <node> and port <port> and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
    1. Replace `<node>` with the node and `<port>` with the port from the previous step
 7. Go to the browser window, reload a few times
 8. Switch back to the terminal, show how all the traffic is TLS-encrypted gibberish
 9. Hit _Cntl-C_ to exit tcpdump
 10. `exit` to close the SSH connection

### Connect to the `listing` service

 1. `terraform output listing_api_servers` 
 2. `ssh ubuntu@<first ip returned>`
    1. When asked `Are you sure you want to continue connecting (yes/no)?` answer `yes` and hit enter
 3. `cat /lib/systemd/system/listing.service`
    1. Look at the lines
    ```
    Environment=LISTING_PORT=8000
    Environment=LISTING_ADDR=127.0.0.1
    ```
    2. Point out that what this tells the `listing` service to do is to _only_ listen on `localhost`, port
       8000
 4. `cat /etc/consul/listing.hcl`
    1. Look at the `connect=` stanza
    2. Point out that not only is this allowing the `listing` service to connect to `mongodb` via Connect,
       but it's also making `listing` availble over connect

### Making the connection

 1. Point out that all you did to change a standard Node application was to configure Consul Connecat and  _tell the app to listen only on localhost_
    1. `listing` knows _nothing_ about TLS
    2. `listing` knows _nothing_ about mutual-TLS authentication
    4. `listing` doesn't have to manage certificates, keys, CRLs, CA certs...
    5. `listing` simply sees _simple, unencrypted traffic_ coming to it
 2. Point out that by configuring `listing` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_
 3. Point out that to connect `web_client` to it's backend services, all you had to do was 
    1. Enable Connect
    2. Tell `web_client` that it's upstream services are reachable on localhost ports
    3. Consul Connect handles balancing traffic between 1, 2, 20, 100 healthy instances
    4. Consul Connect _encrypts_ all network traffic
    5. `web_client` knows _nothing_ about TLS
    6. `web_client` knows _nothing_ about mutual-TLS authentication
    7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
    8. `web_client` simply makes the same _simple, unencrypted requests_ it always has

### Intentions

Still on the `listing` server

 1. `consul intention create -deny '*' '*'`
    1. We've now told Consul Connect that by default, do not allow any traffic
 2. Switch to the web browser and reload. Note that it says it has problems reaching the APIs
 3. Switch back to the terminal
 4. `consul intention create -allow 'web_client' 'listing'`
 5. Switch back to the web browser and reload. See how it can now reach the `listing` API
 6. Switch back to the terminal
 7. `consul intention create -allow 'web_client' 'product'`
 8. Switch back to the web browser and reload. See how it can now reach the `product` API
 9. Switch back to the terminal
 10. `consul intention delete 'web_client' 'product'`
 11. Switch back to the web browser and reload. See how the `product` API is now unreachable again
 12. Point out that if you had 6 `web_client` instances, 17 `listing` instances and 23 `product` instances,
     you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define
 13. Point out that you've replaced those with _2_ intention definitions
 14. Point out that the intentions follow the service. If you double the number of backends, you
     have to add _another_ 240 endpoint combinations, but you do _nothing_ because intentions follow
     the service
