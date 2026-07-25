resource "ncloud_route_table" "this" {
  for_each = {
    for rt in var.route_tables : rt.name => rt
  }

  vpc_no = var.vpc_id
  name   = each.value.name

  supported_subnet_type = each.value.subnet_type
}


resource "ncloud_route" "nat" {
  for_each = {
    for rt in var.route_tables :
    rt.name => rt
    if rt.target_type == "NATGW" && var.nat_gateway_id != null && var.nat_gateway_name != null
  }

  route_table_no         = ncloud_route_table.this[each.key].id
  target_no              = var.nat_gateway_id
  target_name            = var.nat_gateway_name
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
}

resource "ncloud_route_table_association" "this" {
  for_each = {
    for pair in flatten([
      for rt in var.route_tables : [
        for sn in rt.subnet_names : {
          key     = "${rt.name}-${sn}"
          rt_name = rt.name
          sn_name = sn
        }
      ]
    ]) : pair.key => pair
  }

  route_table_no = ncloud_route_table.this[each.value.rt_name].id
  subnet_no = coalesce(
    lookup(var.public_subnet_map, each.value.sn_name, null),
    lookup(var.private_subnet_map, each.value.sn_name, null)
  )
}
