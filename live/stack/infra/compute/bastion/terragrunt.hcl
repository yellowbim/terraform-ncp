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

dependency "init_script" {
  config_path = "../init-script"
}


dependency "acgs" {
  config_path = "../acg"
}


terraform {
  source = "${include.root.locals.root}/modules/compute/bastion"
}

inputs = {
  name                = local.env_cfg.locals.bastion.name
  subnet_no           = dependency.subnet.outputs.public_subnet_map[local.env_cfg.locals.bastion.subnet_name]
  server_image_number = local.env_cfg.locals.bastion.server_image_number
  server_spec_code    = local.env_cfg.locals.bastion.server_spec_code
  login_key_name      = local.env_cfg.locals.bastion.login_key_name
  # init_script_no      = dependency.init_script.outputs.init_scripts[local.env_cfg.locals.bastion.init_script_name]
  init_script_no = dependency.init_script.outputs.init_script_id
  acg_nos = [
    dependency.acgs.outputs.acg_nos["bastion"]
  ]
}
