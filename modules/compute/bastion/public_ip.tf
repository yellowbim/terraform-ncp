# Bastion 용 public ip 생성
resource "ncloud_public_ip" "bastion" {
  description        = "bastion public ip"
  server_instance_no = ncloud_server.bastion.id

}
