# IAM Policies

# Consul IAM Instance Policy
resource "aws_iam_instance_profile" "consul_iam_profile" {
  name = "${var.project_name}-consul_profile"
  role = "${aws_iam_role.consul_iam_role.name}"
}

resource "aws_iam_role" "consul_iam_role" {
  name               = "${var.project_name}-consul_role"
  description        = "CC Demo Consul Server IAM Role"
  assume_role_policy = "${data.aws_iam_policy_document.consul_assume_role.json}"
}

data "aws_iam_policy_document" "consul_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Allow Consul call ec2:DescribeInstances & ec2:DescribeTags for Cloud AutoJoin
resource "aws_iam_role_policy" "consul_iam_role_policy" {
  name   = "${var.project_name}-consul_policy"
  role   = "${aws_iam_role.consul_iam_role.id}"
  policy = "${data.aws_iam_policy_document.consul_policy.json}"
}

data "aws_iam_policy_document" "consul_policy" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}
