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

dependency "subnet" {
  config_path = "${get_repo_root()}/live/global/network/subnet"
}

dependency "cluster" {
  config_path = "../cluster"
}


terraform {
  source = "${include.root.locals.root}/modules/nks/node"
}

inputs = {
  cluster_uuid = dependency.cluster.outputs.cluster_uuid
  # subnet_nos   = dependency.subnet.outputs.subnet_ids
  node_pools = local.env_cfg.locals.nks.node_pools
}
