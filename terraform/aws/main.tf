# Create consult connect demo cluster & configure

module "cluster_main" {
  source = "modules/consul-demo-cluster"

  aws_region    = "${var.aws_region}"
  consul_dc     = "${var.consul_dc}"
  consul_acl_dc = "${var.consul_acl_dc}"

  project_name     = "${var.project_name}"
  top_level_domain = "${var.top_level_domain}"

  route53_zone_id = "${var.route53_zone_id}"
  ssh_key_name    = "${var.ssh_key_name}"
  consul_lic      = "${var.consul_lic}"

  # hashi_tags = "${var.hashi_tags}"
  hashi_tags = {
    project = "${var.tag_project}"
    owner   = "${var.tag_owner}"
    ttl     = "${var.tag_ttl}"
  }
}

# Configure the Consul Cluster
provider "consul" {
  address    = "${element(module.cluster_main.consul_servers, 0)}:8500"
  datacenter = "${var.consul_dc}"
}

resource "consul_prepared_query" "product_service" {
  datacenter   = "${var.consul_dc}"
  name         = "product"
  only_passing = true
  connect      = true

  service = "product"

  failover {
    datacenters = ["${var.consul_dc}"]
  }
}
