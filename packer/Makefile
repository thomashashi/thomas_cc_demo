ENCRYPT_CONFIG := files/encrypt.hcl


DEFAULT:
	@echo Run 'make gcp' or 'make aws' to build appropriate images
	@echo Set the environment variable DC_NAME to name the images

aws: aws_consul_server aws_vault_server

aws_consul_base: .built.aws_consul_base

aws_consul_client: aws_consul_base .built.aws_consul_client

aws_consul_server: aws_consul_client .built.aws_consul_server

aws_vault_server: aws_consul_client .built.aws_vault_server

.built.aws_consul_base: consul_base.json files/install_base.sh files/install_consul.sh
	DC_NAME=east packer build -only amazon-ebs consul_base.json
	touch .built.aws_consul_base

.built.aws_consul_client: consul_client.json files/client-join-aws.hcl files/client.hcl
	DC_NAME=east packer build -only amazon-ebs consul_client.json
	touch .built.aws_consul_client

.built.aws_consul_server: consul_server.json files/server.hcl files/server-join-aws.hcl
	DC_NAME=east packer build -only amazon-ebs consul_server.json
	touch .built.aws_consul_server

.built.aws_vault_server: vault_server.json files/vault_config.hcl files/vault_awskms_config.hcl files/install_vault.sh files/enable_vault_acl.sh
	DC_NAME=east packer build -only amazon-ebs vault_server.json
	touch .built.aws_vault_server

$(ENCRYPT_CONFIG):
	$(if $(shell PATH=$(PATH) which consul),,$(error "No consul in PATH"))
	@echo Making encryption key
	echo "encrypt = $$(consul keygen)" > $(ENCRYPT_CONFIG)



