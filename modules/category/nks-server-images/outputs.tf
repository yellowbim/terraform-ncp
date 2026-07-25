output "all_images" {
  value = data.ncloud_nks_server_images.all.images
}

output "filtered_images" {
  value = local.filtered_images
}
