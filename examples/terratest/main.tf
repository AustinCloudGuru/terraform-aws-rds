#------------------------------------------------------------------------------
# Provider
#------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  name                         = "terratest-vpc"
  cidr                         = "10.0.0.0/16"
  azs                          = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets               = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets             = ["10.0.201.0/24", "10.0.202.0/24"]
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  tags                         = var.tags
}

module "rds" {
  source               = "../../"
  name                 = "terratest"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group
  deletion_protection  = false
  multi_az             = false
  skip_final_snapshot  = true
}
