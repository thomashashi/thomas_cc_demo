data "aws_ami" "consul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-consul-server-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "mongo-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-mongodb-noconnect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "mongo-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-mongodb-connect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "product-api-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-product-noconnect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "product-api-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-product-connect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "listing-api" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-listing-server-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "webclient-connect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-webclient-connect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}

data "aws_ami" "webclient-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-webclient-noconnect-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}
