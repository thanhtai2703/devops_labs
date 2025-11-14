output "vpc_id" {
  description = "ID của VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID của Public Subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID của Private Subnet"
  value       = aws_subnet.private.id
}