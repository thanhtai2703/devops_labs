# Outputs từ các modules

# VPC Outputs
output "vpc_id" {
  description = "ID của VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID của Public Subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID của Private Subnet"
  value       = module.vpc.private_subnet_id
}

# Security Group Outputs
output "public_sg_id" {
  description = "ID của Public Security Group"
  value       = module.security_groups.public_sg_id
}

output "private_sg_id" {
  description = "ID của Private Security Group"
  value       = module.security_groups.private_sg_id
}

# EC2 Outputs
output "public_ec2_ip" {
  description = "IP Public của EC2 instance trong Public Subnet"
  value       = module.ec2.public_ec2_ip
}

output "private_ec2_ip" {
  description = "IP Private của EC2 instance trong Private Subnet"
  value       = module.ec2.private_ec2_ip
}

# Thông tin hướng dẫn SSH
output "ssh_command" {
  description = "Lệnh SSH để kết nối vào Public EC2"
  value       = "ssh -i <your-key.pem> ec2-user@${module.ec2.public_ec2_ip}"
}
