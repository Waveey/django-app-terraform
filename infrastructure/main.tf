# provider "aws" {
#   region = var.aws_region
# }

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment         = var.environment
}

module "s3" {
  source = "./modules/s3"
  
  bucket_name    = var.bucket_name
  environment    = var.environment
  ec2_role_name  = module.iam.ec2_role_name
}

module "iam" {
  source = "./modules/iam"
  
  environment    = var.environment
  s3_bucket_name = var.bucket_name
}

module "rds" {
  source = "./modules/rds"
  
  environment            = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  ec2_security_group_id = module.asg.ec2_security_group_id 

}

module "asg" {
  source = "./modules/asg"
  
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  desired_capacity   = var.desired_capacity
  max_size          = var.max_size
  min_size          = var.min_size
  admin_cidr_blocks = var.admin_cidr_blocks
  key_name = var.key_name
  rds_endpoint = module.rds.rds_endpoint
}