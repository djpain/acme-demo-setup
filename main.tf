provider aws {
  region = "ap-southeast-2"
}

module "vpc" {
  source      = "./module/VPC/"
  vpcname     = var.vpcname
  namespace   = var.namespace
  environment = terraform.workspace
  region      = var.region
}
# module "postgres_sg" {
#   source  = "./module/SG/"
#   dbvpcid = module.vpc.vpc_id
#   sg_name = var.dbsgname

# }
# module "fe" {
#   source      = "./module/FE/"
#   bucketname  = var.bucketname
#   region      = var.region
#   namespace   = var.namespace
#   environment = terraform.workspace
# }

module "eks" {
  source        = "./module/EKS/"
  namespace     = var.namespace
  environment   = terraform.workspace
  region        = var.region
  privatesubnet = module.vpc.private_subnets
  vpc_id        = module.vpc.vpc_id
}

module "rds" {
  source = "./module/RDS/"
  #sg_name     = module.postgres_sg.security_group_id
  vpcname     = var.vpcname
  namespace   = var.namespace
  environment = terraform.workspace
  pgdbname    = var.dbname
  pgusername  = var.dbusername
  pgpassword  = var.dbpassword
  region      = var.region
  pgsubnet    = module.vpc.private_subnets
}
