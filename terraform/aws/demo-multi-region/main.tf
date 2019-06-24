# Consul Connect Demo Cluster - Single Region

# Create MAIN Consul Connect cluster
module "cluster_main" {
  source = "../modules/consul-demo-cluster"

  aws_region    = "${var.aws_region}"
  consul_dc     = "${var.consul_dc}"
  consul_acl_dc = "${var.consul_dc}"
  vpc_netblock  = "10.0.0.0/16"

  project_name     = "${var.project_name}"
  top_level_domain = "${var.top_level_domain}"

  route53_zone_id = "${var.route53_zone_id}"
  ssh_key_name    = "${var.ssh_key_name}"
  consul_lic      = "${var.consul_lic}"

  hashi_tags = "${var.hashi_tags}"
}

# Create ALTERNATE Consul Connect cluster
module "cluster_alt" {
  source = "../modules/consul-demo-cluster"

  aws_region    = "${var.aws_region_alt}"
  consul_dc     = "${var.consul_dc_alt}"
  consul_acl_dc = "${var.consul_dc}"
  vpc_netblock  = "10.128.0.0/16"

  project_name     = "${var.project_name}"
  top_level_domain = "${var.top_level_domain}"

  route53_zone_id = "${var.route53_zone_id}"
  ssh_key_name    = "${var.ssh_key_name}"
  consul_lic      = "${var.consul_lic}"

  hashi_tags = "${var.hashi_tags}"
}

# Configure MAIN Consul Cluster for Prepared Query
provider "consul" {
  alias = "main"

  address    = "${element(module.cluster_main.consul_servers, 0)}:8500"
  datacenter = "${module.cluster_main.consul_dc}"
}

resource "consul_prepared_query" "product_service_main" {
  provider = "consul.main"

  datacenter   = "${module.cluster_main.consul_dc}"
  name         = "product"
  only_passing = true
  connect      = true

  service = "product"

  failover {
    datacenters = ["${module.cluster_main.consul_dc}", "${module.cluster_alt.consul_dc}"]
  }
}

# Configure ALTERNATE Consul Cluster for Prepared Query
provider "consul" {
  alias = "alt"

  address    = "${element(module.cluster_alt.consul_servers, 0)}:8500"
  datacenter = "${module.cluster_alt.consul_dc}"
}

resource "consul_prepared_query" "product_service_alt" {
  provider = "consul.alt"

  datacenter   = "${module.cluster_alt.consul_dc}"
  name         = "product"
  only_passing = true
  connect      = true

  service = "product"

  failover {
    datacenters = ["${module.cluster_main.consul_dc}", "${module.cluster_alt.consul_dc}"]
  }
}

# Link VPCs
module "link_vpc" {
  source = "../modules/link-vpc"

  aws_region_main     = "${var.aws_region}"
  aws_region_alt      = "${var.aws_region_alt}"
  vpc_id_main         = "${module.cluster_main.vpc_id}"
  vpc_id_alt          = "${module.cluster_alt.vpc_id}"
  route_table_id_main = "${module.cluster_main.vpc_public_route_table_id}"
  route_table_id_alt  = "${module.cluster_alt.vpc_public_route_table_id}"

  hashi_tags = "${var.hashi_tags}"
}
