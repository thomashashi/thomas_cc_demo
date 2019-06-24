# Outputs

# Main Cluster Region
output "main_region" {
  value = "${module.cluster_main.aws_region}"
}

output "main_consul_lb" {
  value = "${module.cluster_main.consul_lb}"
}

output "main_consul_servers" {
  value = ["${module.cluster_main.consul_servers}"]
}

output "main_webclient_lb" {
  value = "${module.cluster_main.webclient_lb}"
}

output "main_webclient_servers" {
  value = ["${module.cluster_main.webclient_servers}"]
}

output "main_listing_api_servers" {
  value = ["${module.cluster_main.listing_api_servers}"]
}

output "main_mongo_servers" {
  value = ["${module.cluster_main.mongo_servers}"]
}

output "main_product_api_servers" {
  value = ["${module.cluster_main.product_api_servers}"]
}

# Alternate Cluster Outputs
output "alt_region" {
  value = "${module.cluster_alt.aws_region}"
}

output "alt_consul_lb" {
  value = "${module.cluster_alt.consul_lb}"
}

output "alt_consul_servers" {
  value = ["${module.cluster_alt.consul_servers}"]
}

output "alt_webclient_lb" {
  value = "${module.cluster_alt.webclient_lb}"
}

output "alt_webclient_servers" {
  value = ["${module.cluster_alt.webclient_servers}"]
}

output "alt_listing_api_servers" {
  value = ["${module.cluster_alt.listing_api_servers}"]
}

output "alt_mongo_servers" {
  value = ["${module.cluster_alt.mongo_servers}"]
}

output "alt_product_api_servers" {
  value = ["${module.cluster_alt.product_api_servers}"]
}
