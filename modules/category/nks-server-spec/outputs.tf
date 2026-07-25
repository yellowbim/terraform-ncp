output "nks_server_products_raw" {
  value = data.ncloud_nks_server_products.all
}

output "nks_server_products" {
  value = data.ncloud_nks_server_products.all.products
}

output "nks_server_spec_codes" {
  value = [
    for p in data.ncloud_nks_server_products.all.products :
    p.value
  ]
}

output "nks_server_specs_summary" {
  value = [
    for p in data.ncloud_nks_server_products.all.products : {
      code  = p.value
      label = p.label
    }
  ]
}
