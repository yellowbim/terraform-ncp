############### Subnet
# subnet 생성 파일
locals {
  flat_subnets = flatten([
    for group, items in var.subnets : [
      for s in items : merge(s, {
        group = group
      })
    ]
  ])
}

resource "ncloud_subnet" "this" {
  for_each = {
    for s in local.flat_subnets : s.name => s
  }

  vpc_no         = var.vpc_id
  network_acl_no = var.default_network_acl_no
  subnet         = each.value.cidr
  zone           = each.value.zone
  subnet_type    = each.value.group == "public" ? "PUBLIC" : "PRIVATE"
  name           = each.value.name
  usage_type     = each.value.usage_type
}
