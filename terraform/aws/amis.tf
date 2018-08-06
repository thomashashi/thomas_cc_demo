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

data "aws_ami" "mongo" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["east-aws-ubuntu-mongodb-*"]
    }

    filter {
        name   = "tag:owner"
        values = ["thomas@hashicorp.com"]
    }
}
