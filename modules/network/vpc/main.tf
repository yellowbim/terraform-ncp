############### VPC
# 현재 계정의 VPC 목록 조회
data "ncloud_vpcs" "all" {
}

locals {
  existing_vpc_candidates = [
    for v in data.ncloud_vpcs.all.vpcs : v
    if(
      try(v.name, "") == var.vpc.name &&
      try(v.ipv4_cidr_block, try(v.cidr, "")) == var.vpc.cidr
    )
  ]

  reuse_vpc             = length(local.existing_vpc_candidates) > 0
  selected_existing_vpc = local.reuse_vpc ? one(local.existing_vpc_candidates) : null
}

# vpc(name/cidr)로 조회해 없으면 생성
resource "ncloud_vpc" "this" {
  count = local.reuse_vpc ? 0 : 1

  name            = var.vpc.name
  ipv4_cidr_block = var.vpc.cidr
}
