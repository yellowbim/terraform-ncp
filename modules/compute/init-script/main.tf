# Init Script 생성 (콘솔의 Script 생성)
resource "ncloud_init_script" "this" {
  name        = var.init_script_name
  description = var.init_script_desc

  content = templatefile(
    "${path.module}/${var.init_script_template}",
    {
      ADMIN_USER     = var.admin_user
      ADMIN_PASSWORD = var.admin_password
      PROM_PASSWORD  = var.prom_password
    }
  )
}
