# ssh pem 생성 파일
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ncloud_login_key" "ssh_key" {
  key_name = var.key_name
}

resource "local_file" "ssh_pem" {
  content         = ncloud_login_key.ssh_key.private_key
  filename        = "${var.output_dir}/${var.key_name}.pem"
  file_permission = "0600"
}