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
  config_path = "${get_repo_root()}/live/global/network/vpc"
}

dependency "subnet" {
  config_path = "${get_repo_root()}/live/global/network/subnet"
}


terraform {
  source = "${include.root.locals.root}/modules/nks/cluster"
}

inputs = {
  name            = local.env_cfg.locals.nks.cluster.name
  hypervisor_code = local.env_cfg.locals.nks.cluster.hypervisor_code
  k8s_version     = local.env_cfg.locals.nks.cluster.k8s_version

  login_key_name = local.env_cfg.locals.bastion.login_key_name
  login_user_id  = local.env_cfg.locals.nks.cluster.login_user_id

  zone = local.env_cfg.locals.nks.cluster.zone

  vpc_id         = dependency.vpc.outputs.vpc_id
  subnet_no_list = dependency.subnet.outputs.worker_private_subnet_ids
  lb_private_subnet_no = dependency.subnet.outputs.private_subnet_map[
    local.env_cfg.locals.nks.cluster.lb_private_subnet_name
  ]
  lb_public_subnet_no = dependency.subnet.outputs.public_subnet_map[
    local.env_cfg.locals.nks.cluster.lb_public_subnet_name
  ]
}
