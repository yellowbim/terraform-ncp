# 결과 파일
output "init_script_id" {
  value = ncloud_init_script.this.id
}

output "init_script_name" {
  value = ncloud_init_script.this.name
}

output "init_scripts" {
  value = {
    "${ncloud_init_script.this.name}" = ncloud_init_script.this.id
  }
}