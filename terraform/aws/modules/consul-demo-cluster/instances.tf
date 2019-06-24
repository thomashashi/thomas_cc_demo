# Create Instances

# Deploy Consul Cluster
data "aws_ami" "consul" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["cc-demo-consul-server-*"]
  }
}

resource aws_instance "consul" {
  ami                         = "${data.aws_ami.consul.id}"
  count                       = "${var.consul_servers_count}"
  instance_type               = "${var.server_machine_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.svr_default.id}", "${aws_security_group.consul_server.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul_iam_profile.name}"
  user_data_base64            = "${base64encode(var.consul_lic)}"

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-consul-server"), map("role", "consul-server"), map("consul-cluster-name", replace("consul-cluster-${local.unique_proj_id}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"
}

# Deploy Webclient servers
data "aws_ami" "webclient" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["cc-demo-webclient-*"]
  }
}

resource aws_instance "webclient" {
  ami                         = "${data.aws_ami.webclient.id}"
  count                       = "${var.client_webclient_count}"
  instance_type               = "${var.client_machine_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.svr_default.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul_iam_profile.name}"

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-webclient-server-${count.index}"), map("role", "webclient-server"), map("consul-cluster-name", replace("consul-cluster-${local.unique_proj_id}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"

  depends_on = ["aws_instance.consul"]
}

# Deploy Listing API Servers
data "aws_ami" "listing-api" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["cc-demo-listing-server-*"]
  }
}

resource aws_instance "listing-api" {
  ami                         = "${data.aws_ami.listing-api.id}"
  count                       = "${var.client_listing_count}"
  instance_type               = "${var.client_machine_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.svr_default.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul_iam_profile.name}"

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-listing-api-server-${count.index}"), map("role", "listing-api-server"), map("consul-cluster-name", replace("consul-cluster-${local.unique_proj_id}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"

  depends_on = ["aws_instance.consul"]
}

# Deploy Product API Servers
data "aws_ami" "product-api" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["cc-demo-product-*"]
  }
}

resource aws_instance "product-api" {
  ami                         = "${data.aws_ami.product-api.id}"
  count                       = "${var.client_product_count}"
  instance_type               = "${var.client_machine_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.svr_default.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul_iam_profile.name}"

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-product-api-server-${count.index}"), map("role", "product-api-server"), map("consul-cluster-name", replace("consul-cluster-${local.unique_proj_id}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"

  depends_on = ["aws_instance.consul"]
}

# Deploy MongoDB Server
data "aws_ami" "mongo" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["cc-demo-mongodb-*"]
  }
}

resource aws_instance "mongo" {
  ami                         = "${data.aws_ami.mongo.id}"
  count                       = "${var.client_db_count}"
  instance_type               = "${var.client_machine_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.svr_default.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.consul_iam_profile.name}"

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-mongo-server-${count.index}"), map("role", "mongo-server"), map("consul-cluster-name", replace("consul-cluster-${local.unique_proj_id}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"

  depends_on = ["aws_instance.consul"]
}
