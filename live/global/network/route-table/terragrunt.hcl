locals {
  selected_project = get_env("TG_PROJECT")
  selected_env     = get_env("TG_ENV")
  project_cfg      = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/project.hcl")
  env_cfg          = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/${local.selected_env}.hcl")
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "backend" {
  path = find_in_parent_folders("backend.hcl")
}

include "provider" {
  path = find_in_parent_folders("provider.hcl")
}

include "versions" {
  path = find_in_parent_folders("versions.hcl")
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

dependency "subnet" {
  config_path = "../../network/subnet"
}

dependency "nat_gateway" {
  config_path = "../../network/nat-gateway"
}

terraform {
  source = "${include.root.locals.root}/modules/network/route-table"
}


inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  public_subnet_map  = dependency.subnet.outputs.public_subnet_map
  private_subnet_map = dependency.subnet.outputs.private_subnet_map

  nat_gateway_id   = dependency.nat_gateway.outputs.nat_gateway_id
  nat_gateway_name = dependency.nat_gateway.outputs.nat_gateway_name

  route_tables = local.env_cfg.locals.route_tables
}
