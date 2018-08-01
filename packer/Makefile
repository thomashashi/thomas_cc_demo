ENCRYPT_CONFIG := files/encrypt.hcl


DEFAULT:
	@echo Run 'make gcp' or 'make aws' to build appropriate images
	@echo Set the environment variable DC_NAME to name the images

aws: aws_consul_base

aws_consul_base: .built.aws_consul_base

.built.aws_consul_base: consul_base.json files/install_base.sh files/install_consul.sh
	DC_NAME=east packer build -only amazon-ebs consul_base.json
	touch .built.aws_consul_base

$(ENCRYPT_CONFIG):
	$(if $(shell PATH=$(PATH) which consul),,$(error "No consul in PATH"))
	@echo Making encryption key
	echo "encrypt = $$(consul keygen)" > $(ENCRYPT_CONFIG)



