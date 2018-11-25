# Deploy a Consul Cluster

resource aws_instance "consul" {
    ami                         = "${data.aws_ami.consul.id}"
    count			= "${var.consul_servers_count}"
    instance_type		= "${var.server_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(aws_subnet.public.*.id, count.index)}" 
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.consul_server_sg.id}"]
    iam_instance_profile        = "${aws_iam_instance_profile.consul_server_iam_profile.name}"
    user_data_base64		= "${base64encode(var.consul_lic)}"
    
    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-consul-server"), map("role", "consul-server"), map("consul-cluster-name", replace("consul-cluster-${var.project_name}-${var.hashi_tags["owner"]}", " ", "")), map("consul-cluster-dc-name", "${var.consul_dc}"), map("consul-cluster-acl-dc-name", "${var.consul_acl_dc}"))}"
}

output "consul_servers" {
    value = ["${aws_instance.consul.*.public_dns}"]
}

resource "aws_route53_record" "consul_a_records" {
    count = "${var.consul_servers_count}"
    zone_id = "${var.route53_zone_id}"
    name = "consul${count.index}.${var.consul_dc}.reinventconsul.hashidemos.io"
    type = "A"
    ttl = "30"
    records = ["${aws_instance.consul.*[count.index].public_ip}"]
}

# Allow Consul Servers to call ec2:DescribeTags for Cloud AutoJoin

resource "aws_iam_instance_profile" "consul_server_iam_profile" {
    name = "${var.project_name}-consul_server_profile"
    role = "${aws_iam_role.consul_server_iam_role.name}"
}

resource "aws_iam_role" "consul_server_iam_role" {
    name        = "${var.project_name}-consul_server_role"
    description = "CC Demo Consul Server IAM Role"

    assume_role_policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
    { 
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "describe_tags" {
    name        = "${var.project_name}-policy-desc"
    role        = "${aws_iam_role.consul_server_iam_role.id}"

    policy = <<EOF
{   
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeTags"
        ],
        "Resource": "*"
    }
}
EOF
}

resource "aws_iam_role_policy" "describe_instances" {
    name = "${var.project_name}-policy-desc-instances"
    role = "${aws_iam_role.consul_server_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
	"Effect": "Allow",
	"Action": [
	    "ec2:DescribeInstances"
	],
	"Resource": "*"
    }
}
EOF
}

# Allow Consul clients also to call ec2:DescribeTags for Cloud AutoJoin

resource "aws_iam_instance_profile" "consul_client_iam_profile" {
    name = "${var.project_name}-consul_client_profile"
    role = "${aws_iam_role.consul_client_iam_role.name}"
}

resource "aws_iam_role" "consul_client_iam_role" {
    name        = "${var.project_name}-consul_client_role"
    description = "CC Demo Consul Client IAM Role"

    assume_role_policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
    { 
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "client_describe_tags" {
    name        = "${var.project_name}-client-policy-desc"
    role        = "${aws_iam_role.consul_client_iam_role.id}"

    policy = <<EOF
{   
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeTags"
        ],
        "Resource": "*"
    }
}
EOF
}

resource "aws_iam_role_policy" "client_describe_instances" {
    name = "${var.project_name}-client-policy-desc-instances"
    role = "${aws_iam_role.consul_client_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
	"Effect": "Allow",
	"Action": [
	    "ec2:DescribeInstances"
	],
	"Resource": "*"
    }
}
EOF
}

# Security groups

resource aws_security_group "consul_server_sg" {
    description = "Traffic allowed to Consul servers"
    vpc_id      = "${aws_vpc.prod.id}"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "consul_server_ssh_from_world" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "consul_server_ui_from_world" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 8500
    to_port           = 8500
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "consul_server_allow_everything_internal" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${var.internal_netblock}"]
}

resource aws_security_group_rule "consul_server_allow_everything_out" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}

# Public LB for consul servers

resource "aws_lb" "consul_lb" {
    name               = "${var.project_name}-c-lb"
    internal           = false
    load_balancer_type = "application"
    subnets            = ["${aws_subnet.public.*.id}"]
    security_groups    = ["${aws_security_group.consul_lb_sg.id}"]

    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-c-lb"))}"
}

resource "aws_lb_target_group" "consul" {
    name     = "${var.project_name}-c-lb-tg"
    port     = 8500
    protocol = "HTTP"
    vpc_id   = "${aws_vpc.prod.id}"

    stickiness = {
	type    = "lb_cookie"
	enabled = false
    }
}

resource "aws_lb_target_group_attachment" "consul" {
    count            = "${var.consul_servers_count}"
    target_group_arn = "${aws_lb_target_group.consul.arn}"
    target_id        = "${element(aws_instance.consul.*.id, count.index)}"

}

resource "aws_lb_listener" "consul_lb" {
    load_balancer_arn = "${aws_lb.consul_lb.arn}"
    port              = 80
    protocol          = "HTTP"

    default_action = {
	target_group_arn = "${aws_lb_target_group.consul.arn}"
	type             = "forward"
    }
}

output "consul-lb" {
    value = "${aws_lb.consul_lb.dns_name}"
}

# Security groups for LB

resource aws_security_group "consul_lb_sg" {
    description = "Traffic allowed to Webclient LB"
    vpc_id      = "${aws_vpc.prod.id}"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "consul_lb_80_from_world" {
    security_group_id = "${aws_security_group.consul_lb_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "consul_lb_everything_in_internal" {
    security_group_id = "${aws_security_group.consul_lb_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${var.internal_netblock}"]
}

resource aws_security_group_rule "consul_lb_everything_out" {
    security_group_id = "${aws_security_group.consul_lb_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
