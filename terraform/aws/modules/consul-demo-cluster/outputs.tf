# Outputs

output "aws_region" {
  value = "${var.aws_region}"
}

output "consul_dc" {
  value = "${var.consul_dc}"
}

output "consul_acl_dc" {
  value = "${var.consul_acl_dc}"
}

output "vpc_id" {
  value = "${aws_vpc.prod.id}"
}

output "vpc_netblock" {
  value = "${var.vpc_netblock}"
}

output "public_subnets" {
  value = "${aws_subnet.public.*.cidr_block}"
}

output "vpc_public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "consul_lb" {
  value = "${aws_route53_record.consul_lb_a_record.fqdn}"
}

output "consul_servers" {
  value = ["${aws_route53_record.consul_a_records.*.fqdn}"]
}

output "consul_servers_private_ip" {
  value = ["${aws_instance.consul.*.private_ip}"]
}

output "webclient_lb" {
  value = "${aws_route53_record.webclient_lb_a_record.fqdn}"
}

output "webclient_servers" {
  value = ["${aws_route53_record.webclient_a_records.*.fqdn}"]
}

output "listing_api_servers" {
  value = ["${aws_route53_record.listing_a_records.*.fqdn}"]
}

output "mongo_servers" {
  value = ["${aws_route53_record.mongo_a_records.*.fqdn}"]
}

output "product_api_servers" {
  value = ["${aws_route53_record.product_a_records.*.fqdn}"]
}
