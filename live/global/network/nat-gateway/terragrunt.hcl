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

terraform {
  source = "${include.root.locals.root}/modules/network/nat-gateway"
}


inputs = {
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_map = dependency.subnet.outputs.public_subnet_map
  nat_gateway       = local.env_cfg.locals.nat_gateway
}
