# 결과 파일
output "private_key" {
  value     = ncloud_login_key.ssh_key.private_key
  sensitive = true
}