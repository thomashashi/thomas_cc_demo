# Load Balancers

# Public LB for consul servers

resource "aws_lb" "consul_lb" {
  name               = "${local.unique_proj_id}-c-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public.*.id}"]
  security_groups    = ["${aws_security_group.lb_default.id}"]

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-c-lb"))}"
}

resource "aws_lb_target_group" "consul" {
  name     = "${local.unique_proj_id}-c-lb-tg"
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

# Public LB for webclient

resource "aws_lb" "webclient-lb" {
  name               = "${local.unique_proj_id}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public.*.id}"]
  security_groups    = ["${aws_security_group.lb_default.id}"]

  tags = "${merge(var.hashi_tags, map("Name", "${local.unique_proj_id}-lb"))}"
}

resource "aws_lb_target_group" "webclient" {
  name     = "${local.unique_proj_id}-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.prod.id}"

  stickiness = {
    type    = "lb_cookie"
    enabled = false
  }
}

resource "aws_lb_target_group_attachment" "webclient" {
  count            = "${var.client_webclient_count}"
  target_group_arn = "${aws_lb_target_group.webclient.arn}"
  target_id        = "${element(aws_instance.webclient.*.id, count.index)}"
}

resource "aws_lb_listener" "webclient-lb" {
  load_balancer_arn = "${aws_lb.webclient-lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action = {
    target_group_arn = "${aws_lb_target_group.webclient.arn}"
    type             = "forward"
  }
}
