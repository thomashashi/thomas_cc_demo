# network security groups

# default security group applied to all servers in demo
resource aws_security_group "svr_default" {
  description = "Traffic allowed to all CC demo servers"
  vpc_id      = "${aws_vpc.prod.id}"
  tags        = "${var.hashi_tags}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.internal_netblock}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group applied to Consul Servers
resource aws_security_group "consul_server" {
  description = "Traffic allowed to Consul servers"
  vpc_id      = "${aws_vpc.prod.id}"
  tags        = "${var.hashi_tags}"

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group applied to LB
resource aws_security_group "lb_default" {
  description = "Traffic allowed to CC Demo Load Balancers"
  vpc_id      = "${aws_vpc.prod.id}"
  tags        = "${var.hashi_tags}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.internal_netblock}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
