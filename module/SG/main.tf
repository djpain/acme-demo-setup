module "postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name                = var.sg_name
  description         = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id              = var.dbvpcid
  #region              = var.region
  ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_rules       = ["postgresaccess"]
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "10.10.0.0/16"
    },
  ]
}