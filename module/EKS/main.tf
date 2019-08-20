terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = var.region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_availability_zones" "available" {
}
data "aws_caller_identity" "available" {
  provider = aws
}

locals {
  cluster_name = "${var.namespace}-eks-${random_string.suffix.result}"
}
locals {
  eks_map_roles = [
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.available.account_id}:role/xxxxx"
      username = "admin:{{SessionName}}"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.available.account_id}:role/xxxxxxx"
      username = "admin:{{SessionName}}"
      group    = "system:masters"
    },
  ]
}
resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = var.privatesubnet

  tags = {
    Environment = var.environment
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = local.eks_map_roles
  map_users                            = [aws_caller_identity.available.caller_user]
  map_accounts                         = [aws_caller_identity.available.account_id]
}