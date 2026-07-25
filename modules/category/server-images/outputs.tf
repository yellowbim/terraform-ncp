# 결과 파일
output "image_list" {
  value = {
    for image in data.ncloud_server_image_numbers.all.image_number_list :
    image.server_image_number => {
      name       = image.name
      hypervisor = image.hypervisor_type
    }
  }
}