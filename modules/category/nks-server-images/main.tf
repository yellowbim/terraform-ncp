############################################
# NKS 전체 서버 이미지 조회
############################################
data "ncloud_nks_server_images" "all" {
  hypervisor_code = var.hypervisor_code
}

############################################
# keyword 존재할 때만 필터 실행
############################################
locals {
  keyword_enabled = try(length(trimspace(var.keyword)) > 0, false)

  filtered_images = local.keyword_enabled ? [
    for img in data.ncloud_nks_server_images.all.images :
    img
    if strcontains(lower(img.label), lower(var.keyword))
  ] : []
}


############################################
# 전체 JSON 생성 (항상)
############################################
resource "local_file" "all_images_json" {
  content  = jsonencode(data.ncloud_nks_server_images.all)
  filename = "${var.output_dir}/nks-images-all.json"
}

############################################
# Filter JSON 생성 (keyword 있을 때만)
############################################
resource "local_file" "filtered_images_json" {
  count = local.keyword_enabled ? 1 : 0

  content  = jsonencode(local.filtered_images)
  filename = "${var.output_dir}/nks-images-${var.keyword}.json"
}
