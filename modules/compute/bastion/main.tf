# Bastion Server 생성

resource "ncloud_network_interface" "bastion" {
  subnet_no = var.subnet_no
  name      = "${var.name}-nic"

  access_control_groups = var.acg_nos
}


resource "ncloud_server" "bastion" {
  name = var.name

  subnet_no = var.subnet_no

  server_image_number = var.server_image_number
  server_spec_code    = var.server_spec_code

  login_key_name = var.login_key_name
  init_script_no = var.init_script_no

  network_interface {
    network_interface_no = ncloud_network_interface.bastion.id
    order                = 0
  }

}
