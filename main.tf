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