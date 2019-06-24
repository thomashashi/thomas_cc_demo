# Link two AWS VPCs and add Routes

provider "aws" {
  region = "${var.aws_region_main}"
  alias  = "main"
}

provider "aws" {
  region = "${var.aws_region_alt}"
  alias  = "alt"
}

data "aws_caller_identity" "alt" {
  provider = "aws.alt"
}

resource "aws_vpc_peering_connection" "main" {
  provider      = "aws.main"
  vpc_id        = "${var.vpc_id_main}"
  peer_vpc_id   = "${var.vpc_id_alt}"
  peer_owner_id = "${data.aws_caller_identity.alt.account_id}"
  peer_region   = "${var.aws_region_alt}"
  auto_accept   = false

  tags = "${merge(map("Name", "prod-main-alt-link"), map("Side", "Requestor"), var.hashi_tags)}"
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "alt" {
  provider                  = "aws.alt"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
  auto_accept               = true

  tags = "${merge(map("Name", "prod-main-alt-link"), map("Side", "Acceptor"), var.hashi_tags)}"
}

# Add routes

resource "aws_route" "main_to_alt" {
  provider                  = "aws.main"
  route_table_id            = "${var.route_table_id_main}"
  destination_cidr_block    = "${var.cidr_block_alt}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.main.id}"
}

resource "aws_route" "alt_to_main" {
  provider                  = "aws.alt"
  route_table_id            = "${var.route_table_id_alt}"
  destination_cidr_block    = "${var.cidr_block_main}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection_accepter.alt.id}"
}
