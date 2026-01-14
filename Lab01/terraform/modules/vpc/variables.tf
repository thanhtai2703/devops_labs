variable "project_name" {
  description = "Tên dự án, sẽ được dùng để đặt tên (tag) cho tài nguyên"
  type        = string
  default     = "nhom03"
}

variable "vpc_cidr" {
  description = "Dải IP CIDR cho VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Dải IP CIDR cho Public Subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Dải IP CIDR cho Private Subnet"
  type        = string
  default     = "192.168.2.0/24"
}