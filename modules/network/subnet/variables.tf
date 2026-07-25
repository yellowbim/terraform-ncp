variable "vpc_id" {
  type = string
}

variable "default_network_acl_no" {
  type = string
}

variable "subnets" {
  type = map(list(object({
    name       = string
    cidr       = string
    zone       = string
    usage_type = string
  })))
}
