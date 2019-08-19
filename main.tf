module "vpc" {
  source      = "./module/VPC/"
  vpcname     = var.vpcname
  namespace   = var.namespace
  environment = var.environment
}

module "rds" {
  source      = "./module/RDS/"
  vpcname     = var.vpcname
  namespace   = var.namespace
  environment = var.environment
  pgdbname    = var.dbname
  pgusername  = var.dbusername
  pgpassword  = var.dbpassword
  region      = var.region
  sg_name     = var.dbsgname
  dbvpcid     = module.vpc.vpc_id
  pgsubnet    = module.vpc.private_subnets

}
