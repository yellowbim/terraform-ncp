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

terraform {
  source = "${include.root.locals.root}/modules/network/subnet"
}


inputs = {
  vpc_id                 = dependency.vpc.outputs.vpc_id
  default_network_acl_no = dependency.vpc.outputs.default_network_acl_no
  subnets                = local.env_cfg.locals.subnets
}
