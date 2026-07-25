#################################
# NKS ACG ADD TO BASTION ACG
#################################
resource "ncloud_access_control_group_rule" "this" {
  access_control_group_no = var.target_acg_no

  inbound {
    protocol                       = var.protocol
    source_access_control_group_no = var.source_acg_no
    port_range                     = var.port_range
    description                    = var.description
  }
}
