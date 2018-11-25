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

resource "aws_vpc_peering_connection" "east_west" {
    peer_vpc_id = "${data.terraform_remote_state.west.vpc_id}"
    vpc_id = "${data.terraform_remote_state.east.vpc_id}"
    tags = "${merge(map("Name", "prod-east-west-link"), var.hashi_tags)}"
}
