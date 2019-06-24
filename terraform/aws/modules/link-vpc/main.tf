data "terraform_remote_state" "east" {
  backend = "atlas"

  config {
    name = "kula/consul-reinvent-east"
  }
}

data "terraform_remote_state" "west" {
  backend = "atlas"

  config {
    name = "kula/consul-reinvent-west"
  }
}

provider "aws" {
  region = "${data.terraform_remote_state.east.aws_region}"
  alias  = "east"
}

provider "aws" {
  region = "${data.terraform_remote_state.west.aws_region}"
  alias  = "west"
}

data "aws_caller_identity" "west" {
  provider = "aws.west"
}

resource "aws_vpc_peering_connection" "east" {
  provider      = "aws.east"
  vpc_id        = "${data.terraform_remote_state.east.vpc_id}"
  peer_vpc_id   = "${data.terraform_remote_state.west.vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.west.account_id}"
  peer_region   = "us-west-2"
  auto_accept   = false

  tags = "${merge(map("Name", "prod-east-west-link"), map("Side", "Requestor"), var.hashi_tags)}"
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "west" {
  provider                  = "aws.west"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.east.id}"
  auto_accept               = true

  tags = "${merge(map("Name", "prod-east-west-link"), map("Side", "Acceptor"), var.hashi_tags)}"
}

# Add routes

resource "aws_route" "east_to_west" {
  provider                  = "aws.east"
  route_table_id            = "${data.terraform_remote_state.east.vpc_public_route_table_id}"
  destination_cidr_block    = "10.128.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.east.id}"
}

resource "aws_route" "west_to_east" {
  provider                  = "aws.west"
  route_table_id            = "${data.terraform_remote_state.west.vpc_public_route_table_id}"
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.west.id}"
}
