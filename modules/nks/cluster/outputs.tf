output "cluster_uuid" {
  value = ncloud_nks_cluster.this.uuid
}

output "cluster_name" {
  value = ncloud_nks_cluster.this.name
}

output "endpoint" {
  value = ncloud_nks_cluster.this.endpoint
}

output "acg_no" {
  value = ncloud_nks_cluster.this.acg_no
}
