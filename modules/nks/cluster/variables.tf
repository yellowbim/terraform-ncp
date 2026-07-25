variable "name" {
  type = string
}

variable "hypervisor_code" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "login_key_name" {
  type = string
}

variable "login_user_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_no_list" {
  type = list(string)
}

variable "lb_private_subnet_no" {
  type = string
}

variable "lb_public_subnet_no" {
  type = string
}
