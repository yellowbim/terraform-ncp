output "subnet_ids" {
  description = "All subnet ids (map)"
  value = {
    for k, s in ncloud_subnet.this :
    k => s.id
  }
}

output "private_subnet_map" {
  description = "Private subnet map"
  value = {
    for k, s in ncloud_subnet.this :
    k => s.id if s.subnet_type == "PRIVATE"
  }
}

output "public_subnet_map" {
  description = "Public subnet map"
  value = {
    for k, s in ncloud_subnet.this :
    k => s.id if s.subnet_type == "PUBLIC"
  }
}

output "private_subnet_ids" {
  description = "Private subnet ids (sorted list)"
  value = [
    for k in sort(keys({
      for k, s in ncloud_subnet.this :
      k => s.id if s.subnet_type == "PRIVATE"
    })) :
    {
      for k, s in ncloud_subnet.this :
      k => s.id if s.subnet_type == "PRIVATE"
    }[k]
  ]
}

output "public_subnet_ids" {
  description = "Public subnet ids (sorted list)"
  value = [
    for k in sort(keys({
      for k, s in ncloud_subnet.this :
      k => s.id if s.subnet_type == "PUBLIC"
    })) :
    {
      for k, s in ncloud_subnet.this :
      k => s.id if s.subnet_type == "PUBLIC"
    }[k]
  ]
}

output "worker_private_subnet_ids" {
  value = [
    for s in ncloud_subnet.this :
    s.id
    if s.subnet_type == "PRIVATE" && s.usage_type == "GEN"
  ]
}

output "lb_private_subnet_ids" {
  value = [
    for s in ncloud_subnet.this :
    s.id
    if s.usage_type == "LOADB"
  ]
}
