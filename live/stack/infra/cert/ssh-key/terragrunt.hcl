locals {
  selected_project = get_env("TG_PROJECT")
  selected_env     = get_env("TG_ENV")
  project_cfg      = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/project.hcl")
  env_cfg          = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/${local.selected_env}.hcl")
  output_dir       = "${get_repo_root()}/projects/${local.selected_project}/_generated/${local.selected_env}/cert/ssh-key"
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
  source = "${include.root.locals.root}/modules/cert/ssh-key"

  before_hook "prepare_output_dir" {
    commands = get_terraform_commands_that_need_vars()
    execute  = ["sh", "-c", "mkdir -p '${local.output_dir}'"]
  }
}

inputs = {
  key_name   = local.env_cfg.locals.ssh_key.name
  output_dir = local.output_dir
}
