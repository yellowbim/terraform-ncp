variable "vpc" {
  description = "VPC identifier/spec. Reuse if found by name/cidr, otherwise create."
  type = object({
    name = string
    cidr = string
  })
}
