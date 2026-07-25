variable "target_acg_no" {
  type        = string
  description = "Rule이 추가될 대상 ACG (예: NKS ACG)"
}

variable "source_acg_no" {
  type        = string
  description = "접근을 허용할 source ACG (예: bastion ACG)"
}

variable "protocol" {
  type    = string
  default = "TCP"
}

variable "port_range" {
  type    = string
  default = "1-65535"
}

variable "description" {
  type    = string
  default = "bastion acg link"
}
