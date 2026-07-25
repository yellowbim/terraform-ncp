variable "vpc_id" {
  type = string
}

variable "public_subnet_map" {
  type = map(string)
}

variable "private_subnet_map" {
  type = map(string)
}

variable "nat_gateway_id" {
  type     = string
  default  = null
  nullable = true
}

variable "nat_gateway_name" {
  type     = string
  default  = null
  nullable = true
}

variable "route_tables" {
  type = list(object({
    name         = string
    target_name  = string
    target_type  = string
    subnet_type  = string # ← 이거 반드시 추가
    subnet_names = list(string)
  }))
}
