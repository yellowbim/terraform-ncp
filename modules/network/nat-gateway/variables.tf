variable "vpc_id" {
  type = string
}

variable "public_subnet_map" {
  type = map(string)
}

variable "nat_gateway" {
  type = list(object({
    name        = string
    zone        = string
    subnet_name = string
  }))
}
