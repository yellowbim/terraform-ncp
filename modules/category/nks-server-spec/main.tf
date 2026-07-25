############################################
# NKS 전체 서버 스펙 조회
############################################
data "ncloud_nks_server_products" "all" {
  software_code = var.software_code
  zone          = var.zone
}

############################################
# 전체 JSON 생성 (항상)
############################################
resource "local_file" "all_server_specs_json" {
  content  = jsonencode(data.ncloud_nks_server_products.all)
  filename = "${var.output_dir}/nks-server-spec-all.json"
}
