output "all_versions" {
  value = data.ncloud_nks_versions.all.versions
}

output "filtered_versions" {
  value = local.filtered_versions
}
