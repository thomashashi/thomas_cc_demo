ENCRYPT_CONFIG := files/encrypt.hcl

AMI_OWNER=106962084910

DEFAULT:
	@echo Run 'make gcp' or 'make aws' to build appropriate images

.PHONY: aws
aws: aws_consul_server aws_without_connect aws_with_connect

.PHONY: aws_without_connect
aws_without_connect: aws_client_mongodb_noconnect aws_client_product_noconnect aws_client_webclient_noconnect aws_client_listing_noconnect

.PHONY: aws_with_connect
aws_with_connect: aws_client_mongodb_connect aws_client_product_connect aws_client_webclient_connect aws_client_listing_connect

.PHONY: aws_consul_base
aws_consul_base: .built.aws_consul_base

.PHONY: aws_consul_client
aws_consul_client: aws_consul_base .built.aws_consul_client

.PHONY: aws_consul_server
aws_consul_server: aws_consul_client .built.aws_consul_server

.PHONY: aws_client_listing_connect
aws_client_listing_connect: aws_consul_client aws_client_listing_noconnect .built.aws_client_listing_connect

.PHONY: aws_client_listing_noconnect
aws_client_listing_noconnect: aws_consul_client .built.aws_client_listing_noconnect

.PHONY: aws_client_mongodb_connect
aws_client_mongodb_connect: aws_consul_client aws_client_mongodb_noconnect .built.aws_client_mongodb_connect

.PHONY: aws_client_mongodb_noconnect
aws_client_mongodb_noconnect: aws_consul_client .built.aws_client_mongodb_noconnect

.PHONY: aws_client_product_connect
aws_client_product_connect: aws_consul_client aws_client_product_noconnect .built.aws_client_product_connect

.PHONY: aws_client_product_noconnect
aws_client_product_noconnect: aws_consul_client .built.aws_client_product_noconnect

.PHONY: aws_client_webclient_connect
aws_client_webclient_connect: aws_consul_client aws_client_webclient_noconnect .built.aws_client_webclient_connect

.PHONY: aws_client_webclient_noconnect
aws_client_webclient_noconnect: aws_consul_client .built.aws_client_webclient_noconnect

.built.aws_consul_base: consul_base.json files/install_base.sh files/install_consul.sh
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs consul_base.json
	touch .built.aws_consul_base

.built.aws_consul_client: consul_client.json files/auto-join-aws.hcl.tmpl files/update-consul-join-config files/client.hcl
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs consul_client.json
	touch .built.aws_consul_client

.built.aws_consul_server: consul_server.json files/server.hcl
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs consul_server.json
	touch .built.aws_consul_server

.built.aws_client_listing: client_listing.json files/install_node.sh services/listing.hcl
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_listing.json
	touch .built.aws_client_listing

.built.aws_client_listing_noconnect: client_listing_noconnect.json files/install_node.sh services/listing-noconnect.hcl files/listing.service-noconnect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_listing_noconnect.json
	touch .built.aws_client_listing_noconnect

.built.aws_client_listing_connect: client_listing_connect.json services/listing-connect.hcl files/listing.service-connect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_listing_connect.json
	touch .built.aws_client_listing_connect

.built.aws_client_mongodb_noconnect: client_mongodb_noconnect.json files/install_mongodb.sh services/mongodb-noconnect.hcl files/mongod.conf-noconnect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_mongodb_noconnect.json
	touch .built.aws_client_mongodb_noconnect

.built.aws_client_mongodb_connect: client_mongodb_connect.json services/mongodb-connect.hcl files/mongod.conf-connect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_mongodb_connect.json
	touch .built.aws_client_mongodb_connect

.built.aws_client_product_connect: client_product_connect.json services/product-connect.hcl files/product.service-connect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_product_connect.json
	touch .built.aws_client_product_connect

.built.aws_client_product_noconnect: client_product_noconnect.json services/product-noconnect.hcl files/product.service-noconnect files/install_products.sh
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_product_noconnect.json
	touch .built.aws_client_product_noconnect

.built.aws_client_webclient_connect: client_webclient_connect.json services/web_client-connect.hcl files/web_client.service-connect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_webclient_connect.json
	touch .built.aws_client_webclient_connect

.built.aws_client_webclient_noconnect: client_webclient_noconnect.json files/install_webclient.sh services/web_client-noconnect.hcl files/web_client.service-noconnect
	AMI_OWNER=$(AMI_OWNER) packer build -only amazon-ebs client_webclient_noconnect.json
	touch .built.aws_client_webclient_noconnect

$(ENCRYPT_CONFIG):
	$(if $(shell PATH=$(PATH) which consul),,$(error "No consul in PATH"))
	@echo Making encryption key
	echo "encrypt = $$(consul keygen)" > $(ENCRYPT_CONFIG)



