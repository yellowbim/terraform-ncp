locals {
  route_table_map = {
    for rt in var.route_tables :
    rt.name => rt
  }
}


output "route_table_ids" {
  value = {
    for k, v in ncloud_route_table.this :
    k => v.id
  }
}

output "private_route_table_ids" {
  value = {
    for k, v in ncloud_route_table.this :
    k => v.id
    if local.route_table_map[k].subnet_type == "PRIVATE"
  }
}

output "public_route_table_ids" {
  value = {
    for k, v in ncloud_route_table.this :
    k => v.id
    if local.route_table_map[k].subnet_type == "PUBLIC"
  }
}
