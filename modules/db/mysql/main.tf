resource "ncloud_mysql" "this" {
  service_name       = var.name
  server_name_prefix = var.name

  subnet_no = var.subnet_no

  user_name     = var.user_name
  user_password = var.user_password
  database_name = var.database_name
  host_ip       = var.host_ip

  is_ha         = var.is_ha
  is_multi_zone = var.is_multi_zone
}
