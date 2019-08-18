module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "${var.namespace}"
  name       = "vpc"
  stage      = "${var.stage}"
  cidr_block = "${var.cidr_block}"
}

locals {
  public_cidr_block  = "${cidrsubnet(var.cidr_block, 1, 0)}"
  private_cidr_block = "${cidrsubnet(var.cidr_block, 1, 1)}"
}

module "public_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  availability_zones  = "${var.az}"
  vpc_id              = "${module.vpc.vpc_id}"
  cidr_block          = "${local.public_cidr_block}"
  type                = "public"
  igw_id              = "${var.igw_id}"
  nat_gateway_enabled = "true"
}

module "private_subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  availability_zones = "${var.az}"
  vpc_id             = "${module.vpc.vpc_id}"
  cidr_block         = "${local.private_cidr_block}"
  type               = "private"

  # Map of AZ names to NAT Gateway IDs that was created in "public_subnets" module
  az_ngw_ids = "${module.public_subnets.az_ngw_ids}"

  # Need to explicitly provide the count since Terraform currently can't use dynamic count on computed resources from different modules
  # https://github.com/hashicorp/terraform/issues/10857
  # https://github.com/hashicorp/terraform/issues/12125
  # https://github.com/hashicorp/terraform/issues/4149
  az_ngw_count = 3
}
