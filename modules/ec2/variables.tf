variable "project_name" {
  description = "Tên dự án để tag"
  type        = string
  default     = "devops-project"
}

variable "public_subnet_id" {
  description = "ID của Public Subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID của Private Subnet"
  type        = string
}

variable "public_sg_id" {
  description = "ID của Public Security Group"
  type        = string
}

variable "private_sg_id" {
  description = "ID của Private Security Group"
  type        = string
}

variable "key_name" {
  description = "Tên của Key Pair (file .pem) để SSH"
  type        = string
}