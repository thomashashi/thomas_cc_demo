# Deploy a Webclient server

resource aws_instance "webclient" {
    ami                         = "${data.aws_ami.webclient.id}"
    count			= "${var.client_webclient_count}"
    instance_type		= "${var.client_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(data.aws_subnet_ids.default.ids, count.index)}" 
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.webclient_sg.id}"]
    iam_instance_profile        = "${aws_iam_instance_profile.consul_client_iam_profile.name}"
    
    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-webclient-server-${count.index}"), map("role", "webclient-server"))}"
}

output "webclient_servers" {
    value = ["${aws_instance.webclient.*.public_dns}"]
}

# Security groups

resource aws_security_group "webclient_sg" {
    description = "Traffic allowed to Product API servers"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "webclient_ssh_from_world" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "webclient_allow_everything_internal" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${data.aws_vpc.default.cidr_block}"]
}

resource aws_security_group_rule "webclient_allow_everything_out" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
