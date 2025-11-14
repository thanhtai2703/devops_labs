output "public_ec2_ip" {
  description = "IP Public của máy chủ EC2"
  value       = aws_instance.public.public_ip
}

output "private_ec2_ip" {
  description = "IP Private của máy chủ EC2"
  value       = aws_instance.private.private_ip
}