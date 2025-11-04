terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1" 
}
module "vpc" {
  source = "./modules/vpc" # Đường dẫn đến module vpc
}
module "security_groups" {
  source      = "./modules/security_groups" # Đường dẫn đến module security_groups
  vpc_id      = module.vpc.vpc_id
  user_ip     = var.user_ip
}
module "ec2" {
  source            = "./modules/ec2" # Đường dẫn đến module ec2
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  public_sg_id      = module.security_groups.public_sg_id
  private_sg_id     = module.security_groups.private_sg_id
  key_name          = var.key_name
  project_name      = "myproject"
}