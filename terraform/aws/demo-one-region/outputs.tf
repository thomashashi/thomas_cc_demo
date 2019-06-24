# Outputs

output "main_region" {
  value = "${module.cluster_main.aws_region}"
}

output "consul_lb" {
  value = "${module.cluster_main.consul_lb}"
}

output "consul_servers" {
  value = ["${module.cluster_main.consul_servers}"]
}

output "webclient_lb" {
  value = "${module.cluster_main.webclient_lb}"
}

output "webclient_servers" {
  value = ["${module.cluster_main.webclient_servers}"]
}

output "listing_api_servers" {
  value = ["${module.cluster_main.listing_api_servers}"]
}

output "mongo_servers" {
  value = ["${module.cluster_main.mongo_servers}"]
}

output "product_api_servers" {
  value = ["${module.cluster_main.product_api_servers}"]
}
