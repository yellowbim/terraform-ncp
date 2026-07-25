# NCP 이미지 목록 조회
data "ncloud_server_image_numbers" "all" {}

# JSON 파일 생성
resource "local_file" "image_json" {
  content  = jsonencode(data.ncloud_server_image_numbers.all.image_number_list)
  filename = "${var.output_dir}/image.json"
}