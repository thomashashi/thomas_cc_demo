data "aws_ami" "consul" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-consul-server-*"]
  }
}

data "aws_ami" "mongo-noconnect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-mongodb-noconnect-*"]
  }
}

data "aws_ami" "mongo-connect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-mongodb-connect-*"]
  }
}

data "aws_ami" "product-api-noconnect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-product-noconnect-*"]
  }
}

data "aws_ami" "product-api-connect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-product-connect-*"]
  }
}

data "aws_ami" "listing-api-connect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-listing-server-connect-*"]
  }
}

data "aws_ami" "listing-api-noconnect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-listing-server-noconnect-*"]
  }
}

data "aws_ami" "webclient-connect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-webclient-connect-*"]
  }
}

data "aws_ami" "webclient-noconnect" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["aws-ubuntu-webclient-noconnect-*"]
  }
}
