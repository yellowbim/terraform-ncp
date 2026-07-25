############### nat-gateway
resource "ncloud_nat_gateway" "this" {
  count = length(var.nat_gateway)

  vpc_no = var.vpc_id
  name   = var.nat_gateway[count.index].name
  zone   = var.nat_gateway[count.index].zone

  subnet_no = var.public_subnet_map[
    var.nat_gateway[count.index].subnet_name
  ]
}
