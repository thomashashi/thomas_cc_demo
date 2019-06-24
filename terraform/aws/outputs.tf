# Outputs

output "consul-lb" {
  value = "${module.cluster_main.consul-lb}"
}

output "consul_servers" {
  value = ["${module.cluster_main.consul_servers}"]
}

output "webclient-lb" {
  value = "${module.cluster_main.webclient-lb}"
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
