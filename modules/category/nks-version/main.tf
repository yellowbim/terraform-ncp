############################################
# NKS 전체 서버 이미지 조회
############################################
data "ncloud_nks_versions" "all" {
  hypervisor_code = var.hypervisor_code
}

############################################
# keyword 존재할 때만 필터 실행
############################################
locals {
  keyword_enabled = try(length(trimspace(var.keyword)) > 0, false)

  filtered_versions = local.keyword_enabled ? [
    for img in data.ncloud_nks_versions.all.versions :
    img
    if strcontains(lower(img.label), lower(var.keyword))
  ] : []
}


############################################
# 전체 JSON 생성 (항상)
############################################
resource "local_file" "all_images_json" {
  content  = jsonencode(data.ncloud_nks_versions.all)
  filename = "${var.output_dir}/nks-version-all.json"
}

############################################
# Filter JSON 생성 (keyword 있을 때만)
############################################
resource "local_file" "filtered_versions_json" {
  count = local.keyword_enabled ? 1 : 0

  content  = jsonencode(local.filtered_versions)
  filename = "${var.output_dir}/nks-version-${var.keyword}.json"
}
