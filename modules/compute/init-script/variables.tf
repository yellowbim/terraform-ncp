variable "init_script_template" {
  type = string
}

variable "init_script_name" {
  type = string
}

variable "init_script_desc" {
  type = string
}

variable "admin_user" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "prom_password" {
  type      = string
  sensitive = true
}
