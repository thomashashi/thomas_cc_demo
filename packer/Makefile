ENCRYPT_CONFIG := files/encrypt.hcl


DEFAULT:
	@echo Run 'make gcp' or 'make aws' to build appropriate images
	@echo Set the environment variable DC_NAME to name the images

aws: aws_consul_server aws_vault_server aws_client_listing aws_client_product aws_client_webclient aws_without_connect aws_wit_connect

aws_without_connect: aws_client_mongodb_noconnect

aws_with_connect: aws_client_mongodb_connect

aws_consul_base: .built.aws_consul_base

aws_consul_client: aws_consul_base .built.aws_consul_client

aws_consul_server: aws_consul_client .built.aws_consul_server

aws_vault_server: aws_consul_client .built.aws_vault_server

aws_client_listing: aws_consul_client .built.aws_client_listing

aws_client_mongodb_connect: aws_consul_client aws_client_mongodb_noconnect .built.aws_client_mongodb_connect

aws_client_mongodb_noconnect: aws_consul_client .built.aws_client_mongodb_noconnect

aws_client_product: aws_consul_client .built.aws_client_product

aws_client_webclient: aws_consul_client .built.aws_client_webclient

.built.aws_consul_base: consul_base.json files/install_base.sh files/install_consul.sh
	DC_NAME=east packer build -only amazon-ebs consul_base.json
	touch .built.aws_consul_base

.built.aws_consul_client: consul_client.json files/auto-join-aws.hcl.tmpl files/update-consul-join-config files/client.hcl
	DC_NAME=east packer build -only amazon-ebs consul_client.json
	touch .built.aws_consul_client

.built.aws_consul_server: consul_server.json files/server.hcl files/vault_ca.hcl
	DC_NAME=east packer build -only amazon-ebs consul_server.json
	touch .built.aws_consul_server

.built.aws_vault_server: vault_server.json files/vault_config.hcl files/vault_awskms_config.hcl files/install_vault.sh files/enable_vault_acl.sh
	DC_NAME=east packer build -only amazon-ebs vault_server.json
	touch .built.aws_vault_server

.built.aws_client_listing: client_listing.json files/install_node.sh services/listing.hcl
	DC_NAME=east packer build -only amazon-ebs client_listing.json
	touch .built.aws_client_listing

.built.aws_client_mongodb_noconnect: client_mongodb_noconnect.json files/install_mongodb.sh services/mongodb-noconnect.hcl files/mongod.conf-noconnect
	DC_NAME=east packer build -only amazon-ebs client_mongodb_noconnect.json
	touch .built.aws_client_mongodb_noconnect

.built.aws_client_mongodb_connect: client_mongodb_connect.json services/mongodb-connect.hcl files/mongod.conf-connect
	DC_NAME=east packer build -only amazon-ebs client_mongodb_connect.json
	touch .built.aws_client_mongodb_connect

.built.aws_client_product: client_product.json files/install_products.sh services/product.hcl
	DC_NAME=east packer build -only amazon-ebs client_product.json
	touch .built.aws_client_product

.built.aws_client_webclient: client_webclient.json files/install_webclient.sh services/web_client.hcl
	DC_NAME=east packer build -only amazon-ebs client_webclient.json
	touch .built.aws_client_webclient

$(ENCRYPT_CONFIG):
	$(if $(shell PATH=$(PATH) which consul),,$(error "No consul in PATH"))
	@echo Making encryption key
	echo "encrypt = $$(consul keygen)" > $(ENCRYPT_CONFIG)



