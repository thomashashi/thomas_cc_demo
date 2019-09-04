# Consul Connect Demo Cluster - Single Region

# Create Consult Connect demo cluster
module "cluster_main" {
  source = "../modules/consul-demo-cluster"

  aws_region    = "${var.aws_region}"
  consul_dc     = "${var.consul_dc}"
  consul_acl_dc = "${var.consul_dc}"

  project_name     = "${var.project_name}"
  top_level_domain = "${var.top_level_domain}"

  route53_zone_id = "${var.route53_zone_id}"
  ssh_key_name    = "${var.ssh_key_name}"
  consul_lic      = "${var.consul_lic}"

  hashi_tags = "${var.hashi_tags}"
}

# Configure Prepared Query on Main Consul Cluster
provider "consul" {
  address    = "${element(module.cluster_main.consul_servers, 0)}:8500"
  datacenter = "${module.cluster_main.consul_dc}"
}

resource "consul_prepared_query" "product_service" {
  datacenter   = "${module.cluster_main.consul_dc}"
  name         = "product"
  only_passing = true
  connect      = true

  service = "product"

  failover {
    datacenters = ["${module.cluster_main.consul_dc}"]
  }
}

resource "consul_keys" "keys" {
  key {
    path   = "product/run"
    value  = "true"
    delete = true
  }
}
