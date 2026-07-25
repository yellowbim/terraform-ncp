variable "output_dir" {
  type = string
}

variable "hypervisor_code" {
  type    = string
  default = "KVM"
}

variable "keyword" {
  type    = string
  default = null
}
