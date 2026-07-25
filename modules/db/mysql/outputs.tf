output "mysql_id" {
  value = ncloud_mysql.this.id
}

output "mysql_service_name" {
  value = ncloud_mysql.this.service_name
}

output "private_domain" {
  value = ncloud_mysql.this.mysql_server_list[0].private_domain
}
