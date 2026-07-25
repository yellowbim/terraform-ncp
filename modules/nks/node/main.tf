resource "ncloud_nks_node_pool" "this" {
  for_each = var.node_pools

  cluster_uuid     = var.cluster_uuid
  node_pool_name   = each.value.name
  storage_size     = each.value.storage_size
  software_code    = each.value.software_code
  server_spec_code = each.value.server_spec_code
  node_count       = each.value.node_count

  # subnet_no        = var.subnet_nos[each.value.subnet_name]

  dynamic "label" {
    for_each = lookup(each.value, "labels", {})
    content {
      key   = label.key
      value = label.value
    }
  }

  # autoscaling
  dynamic "autoscale" {
    for_each = lookup(each.value, "enable_autoscaling", false) ? [1] : []
    content {
      enabled = true
      min     = each.value.autoscaling_min_size
      max     = each.value.autoscaling_max_size
    }
  }

  # taints
  dynamic "taint" {
    for_each = lookup(each.value, "taints", [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}
