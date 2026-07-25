# NCP 서버 스펙 목록 조회
data "ncloud_server_specs" "all" {}

# JSON 파일 생성
resource "local_file" "server_specs_json" {
  content  = jsonencode(data.ncloud_server_specs.all.server_spec_list)
  filename = "${var.output_dir}/server_specs.json"
}