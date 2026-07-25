################## 구조 개선
output "vpc_id" {
  description = "VPC ID"
  value = (
    local.reuse_vpc
    ? try(local.selected_existing_vpc.id, local.selected_existing_vpc.vpc_no)
    : ncloud_vpc.this[0].id
  )
}

output "default_network_acl_no" {
  value = (
    local.reuse_vpc
    ? local.selected_existing_vpc.default_network_acl_no
    : ncloud_vpc.this[0].default_network_acl_no
  )
}
