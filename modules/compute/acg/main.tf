#################################
# ACG resources
#################################

resource "ncloud_access_control_group" "this" {
  for_each = var.acgs

  name        = each.value.name
  description = each.value.description
  vpc_no      = var.vpc_id
}

resource "ncloud_access_control_group_rule" "this" {
  for_each = var.acgs

  access_control_group_no = ncloud_access_control_group.this[each.key].id

  dynamic "inbound" {
    for_each = each.value.inbound_rules
    content {
      protocol    = inbound.value.protocol
      ip_block    = inbound.value.ip_block
      port_range  = inbound.value.port_range
      description = inbound.value.description
    }
  }

  dynamic "outbound" {
    for_each = each.value.outbound_rules
    content {
      protocol    = outbound.value.protocol
      ip_block    = outbound.value.ip_block
      port_range  = outbound.value.port_range
      description = outbound.value.description
    }
  }
}
