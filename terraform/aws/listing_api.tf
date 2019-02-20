# Deploy a Listing API server

resource aws_instance "listing-api" {
    ami                         = "${data.aws_ami.listing-api-noconnect.id}"
    count			= "${var.client_listing_count}"
    instance_type		= "${var.client_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(aws_subnet.public.*.id, count.index)}" 
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.listing_server_sg.id}"]
    iam_instance_profile        = "${aws_iam_instance_profile.consul_client_iam_profile.name}"
    
    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-listing-api-server-${count.index}"), map("role", "listing-api-server"), map("consul-cluster-name", replace("consul-cluster-${var.project_name}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"

    depends_on = ["aws_instance.consul"]
}

output "listing_api_servers" {
    value = ["${aws_route53_record.listing_a_records.*.fqdn}"]
}

resource "aws_route53_record" "listing_a_records" {
    count = "${var.client_listing_count}"
    zone_id = "${var.route53_zone_id}"
    name = "listing${count.index}.${var.consul_dc}.${var.top_level_domain}"
    type = "A"
    ttl = "30"
    records = ["${aws_instance.listing-api.*.public_ip[count.index]}"]
}

# Security groups

resource aws_security_group "listing_server_sg" {
    description = "Traffic allowed to Product API servers"
    vpc_id      = "${aws_vpc.prod.id}"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "listing_server_ssh_from_world" {
    security_group_id = "${aws_security_group.listing_server_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "listing_server_allow_everything_internal" {
    security_group_id = "${aws_security_group.listing_server_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${var.internal_netblock}"]
}

resource aws_security_group_rule "listing_server_allow_everything_out" {
    security_group_id = "${aws_security_group.listing_server_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
