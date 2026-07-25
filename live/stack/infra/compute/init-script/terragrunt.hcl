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


terraform {
  source = "${include.root.locals.root}/modules/compute/init-script"
}


inputs = {
  init_script_name     = local.env_cfg.locals.init_script.init_script_name
  init_script_desc     = local.env_cfg.locals.init_script.init_script_desc
  init_script_template = local.env_cfg.locals.init_script.init_script_path

  admin_user     = local.env_cfg.locals.init_script.admin_user
  admin_password = local.env_cfg.locals.init_script.admin_password
  prom_password  = local.env_cfg.locals.init_script.prom_password
}
