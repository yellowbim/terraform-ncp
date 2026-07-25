variable "vpc_id" {
  description = "VPC number"
  type        = string
}

variable "acgs" {
  description = "ACG definitions by role"
  type = map(object({
    name        = string
    description = string

    inbound_rules = list(object({
      protocol    = string
      ip_block    = string
      port_range  = string
      description = string
    }))

    outbound_rules = list(object({
      protocol    = string
      ip_block    = string
      port_range  = string
      description = string
    }))
  }))
}
