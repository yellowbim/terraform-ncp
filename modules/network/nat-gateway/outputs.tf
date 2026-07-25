output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = try(ncloud_nat_gateway.this[0].id, null)
}

output "nat_gateway_name" {
  description = "NAT Gateway NAME"
  value       = try(ncloud_nat_gateway.this[0].name, null)
}
