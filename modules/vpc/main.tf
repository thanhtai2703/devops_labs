# 1. Tạo VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  # Kích hoạt DNS cho VPC
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Tạo Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  #Tự động gán IP công khai cho các EC2
  map_public_ip_on_launch = true 
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# 3. Tạo Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# 4. Tạo Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 5. Tạo NAT Gateway
# NAT Gateway cần một IP Public (Elastic IP) và phải được đặt trong Public Subnet
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main] # Đảm bảo IGW có trước
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}

# 6. Tạo Route Tables
# Public Route Table: Định tuyến ra Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # "0.0.0.0/0" có nghĩa là "tất cả lưu lượng"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Liên kết Public Route Table với Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table: Định tuyến ra NAT Gateway [cite: 21]
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Liên kết Private Route Table với Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# 7. Quản lý Default Security Group
# Mặc dù bài tập có module SG riêng, nhưng Default SG là một phần của VPC.
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  # Thường ta sẽ khoá chặt default SG và không dùng nó
  # Cho phép tất cả traffic đi ra (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Không cho phép traffic đi vào (ingress)
  ingress = []

  tags = {
    Name = "${var.project_name}-default-sg"
  }
}
