# 1. Public EC2 Security Group
#  Cho phép SSH (port 22) từ IP của 
resource "aws_security_group" "public_ec2_sg" {
  name   = "${var.project_name}-public-ec2-sg"
  vpc_id = var.vpc_id
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-ec2-sg"
  }
}
# 2. Private EC2 Security Group
#  Cho phép SSH (port 22) chỉ từ Public EC2 SG
resource "aws_security_group" "private_ec2_sg" {
  name   = "${var.project_name}-private-ec2-sg"
  vpc_id = var.vpc_id

  #  phép SSH chỉ từ Public EC2 SG
  ingress {
    description     = "SSH from Public EC2 SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    
    # Chỉ cho phép kết nối đến từ các EC2 thuộc Public SG
    security_groups = [aws_security_group.public_ec2_sg.id]
  }

  #Cho phép mọi kết nối đi ra
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-ec2-sg"
  }
}