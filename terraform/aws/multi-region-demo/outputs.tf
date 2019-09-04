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
output "secondary_region" {
  value = "${module.cluster_alt.aws_region}"
}

output "secondary_consul_lb" {
  value = "${module.cluster_alt.consul_lb}"
}

output "secondary_consul_servers" {
  value = ["${module.cluster_alt.consul_servers}"]
}

output "secondary_webclient_lb" {
  value = "${module.cluster_alt.webclient_lb}"
}

output "secondary_webclient_servers" {
  value = ["${module.cluster_alt.webclient_servers}"]
}

output "secondary_listing_api_servers" {
  value = ["${module.cluster_alt.listing_api_servers}"]
}

output "secondary_mongo_servers" {
  value = ["${module.cluster_alt.mongo_servers}"]
}

output "secondary_product_api_servers" {
  value = ["${module.cluster_alt.product_api_servers}"]
}

# Display Demo Connection Information at end
output "working_connections" {
  value = <<EOF


  OPEN IN BROWSER TABS
    Webclient   http://${module.cluster_main.webclient_lb}
    Consul GUI  http://${module.cluster_main.consul_lb}

  CONNECT IN TERMINAL TABS:
    ssh ubuntu@${element(module.cluster_main.listing_api_servers, 0)}
    ssh ubuntu@${element(module.cluster_main.webclient_servers, 0)}

EOF
}
