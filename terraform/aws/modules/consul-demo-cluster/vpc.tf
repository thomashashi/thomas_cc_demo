resource "aws_vpc" "prod" {
  cidr_block           = "${var.vpc_netblock}"
  enable_dns_hostnames = true

  tags = "${merge(map("Name", "prod"), var.hashi_tags)}"
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.prod.id}"
  tags   = "${var.hashi_tags}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.prod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags = "${merge(map("Name", "public route table"), var.hashi_tags)}"

  lifecycle {
    ignore_changes = "route"
  }
}

resource "aws_subnet" "public" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  vpc_id            = "${aws_vpc.prod.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(cidrsubnet(var.vpc_netblock, 4, 0), 3, count.index)}"

  tags = "${merge(map("Name", "public"), var.hashi_tags)}"
}

resource "aws_route_table_association" "public" {
  count = "${length(data.aws_availability_zones.available.names)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
