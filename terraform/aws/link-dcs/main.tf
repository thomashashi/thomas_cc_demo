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
    alias = "east"
}

provider "aws" {
    region = "${data.terraform_remote_state.west.aws_region}"
    alias = "west"
}

data "aws_caller_identity" "west" {
  provider = "aws.west"
}

resource "aws_vpc_peering_connection" "east" {
    vpc_id = "${data.terraform_remote_state.east.vpc_id}"
    peer_vpc_id = "${data.terraform_remote_state.west.vpc_id}"
    peer_owner_id = "${data.aws_caller_identity.west.account_id}"
    peer_region = "us-west-2"
    auto_accept = false

    tags = "${merge(map("Name", "prod-east-west-link"), map("Side", "Requestor"), var.hashi_tags)}"
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "west" {
    provider                  = "aws.west"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.west.id}"
    auto_accept               = true

    tags = "${merge(map("Name", "prod-east-west-link"), map("Side", "Acceptor"), var.hashi_tags)}"
}
