# 결과 파일
output "bastion_id" {
  description = "Bastion 서버 ID"
  value       = ncloud_server.bastion.id
}

output "bastion_private_ip" {
  description = "Bastion 서버 Private IP"
  value       = ncloud_server.bastion.private_ip
}

output "bastion_public_ip" {
  description = "Bastion 서버 Public IP"
  value       = ncloud_public_ip.bastion.public_ip
}