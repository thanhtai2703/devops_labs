variable "project_name" {
  description = "Tên dự án để tag"
  type        = string
  default     = "23521380-Lab1"
}

variable "vpc_id" {
  description = "ID của VPC để gắn Security Group vào"
  type        = string
}

variable "user_ip" {
  description = "IP của máy"
  type        = string
}