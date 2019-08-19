provider "aws" {
    region = var.region
}


####################################
# Variables common to both instnaces
####################################
locals {
  engine            = "postgres"
  engine_version    = "11.2"
  instance_class    = "db.t3.small"
  allocated_storage = 5
  port              = "5432"
}

###########
# Master DB
###########
module "master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "${var.namespace}-postgres-master-${var.environment}"

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  name     = var.pgdbname
  username = var.pgusername
  password = var.pgpassword
  port     = local.port

  tags = {
    Owner       = var.namespace
    Environment = var.environment
  }


  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Backups are required in order to create a replica
  backup_retention_period = 1

  # DB subnet group
  subnet_ids = var.pgsubnet

  create_db_option_group    = false
  create_db_parameter_group = false
}

############
# Replica DB
############
module "replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "${var.namespace}-postgres-slave-${var.environment}"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.master.this_db_instance_id

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  # Username and password must not be set for replicas
  username = ""
  password = ""
  port     = local.port

  tags = {
    Owner       = var.namespace
    Environment = var.environment
  }


  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group = false

  create_db_option_group    = false
  create_db_parameter_group = false
}