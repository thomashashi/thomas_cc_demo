provider "aws" {
    region = "${var.aws_region}"
}

output "aws_region" {
    value = "${var.aws_region}"
}
