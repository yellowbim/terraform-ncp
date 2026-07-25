output "acg_nos" {
  description = "ACG numbers by key"
  value = {
    for key, acg in ncloud_access_control_group.this :
    key => acg.access_control_group_no
  }
}
