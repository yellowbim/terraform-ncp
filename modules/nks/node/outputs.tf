output "node_pool_ids" {
  value = [
    for np in ncloud_nks_node_pool.this :
    np.id
  ]
}

# 전체 내용
output "node_pools" {
  description = "All NKS node pools (raw resource objects)"
  value       = ncloud_nks_node_pool.this
}
