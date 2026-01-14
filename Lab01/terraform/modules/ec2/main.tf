
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

# 1. Tạo Public EC2 Instance
resource "aws_instance" "public" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  subnet_id = var.public_subnet_id

  # Gán Public Security Group
  vpc_security_group_ids = [var.public_sg_id]

  # tự động gán IP công khai
  associate_public_ip_address = true

  # Gán key để có thể SSH vào
  key_name = var.key_name

  tags = {
    Name = "${var.project_name}-public-ec2"
  }
}

# 2. Tạo Private EC2 Instance
resource "aws_instance" "private" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  subnet_id = var.private_subnet_id

  # Gán Private Security Group
  vpc_security_group_ids = [var.private_sg_id]

  # KHÔNG gán IP công khai
  associate_public_ip_address = false

  # Gán key để  có thể SSH từ máy public vào
  key_name = var.key_name

  tags = {
    Name = "${var.project_name}-private-ec2"
  }
}