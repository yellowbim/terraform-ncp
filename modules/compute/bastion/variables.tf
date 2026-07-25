# 입력 파일
variable "name" {
  type = string
}

variable "subnet_no" {
  type = string
}

variable "login_key_name" {
  type = string
}

variable "init_script_no" {
  type = string
}

variable "server_image_number" {
  type = string
}

variable "server_spec_code" {
  type = string
}

variable "acg_nos" {
  description = "Access control group numbers"
  type        = list(string)
  default     = []
}
