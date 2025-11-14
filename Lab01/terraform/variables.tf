variable "user_ip" {
  description = "IP của bạn (vào Google gõ 'my ip' và thêm /32)"
  type        = string 
}
variable "key_name"{
  description = "Tên của Key Pair (file .pem) để SSH"
  type        = string
  
}