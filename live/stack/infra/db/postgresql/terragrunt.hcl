locals {
  selected_project  = get_env("TG_PROJECT")
  selected_env      = get_env("TG_ENV")
  project_cfg       = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/project.hcl")
  env_cfg           = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/${local.selected_env}.hcl")
  enable_postgresql = try(local.env_cfg.locals.enable_postgresql, true)
  postgresql_cfg    = try(local.env_cfg.locals.postgresql, null)
}

skip = !local.enable_postgresql

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


terraform {
  source = "${include.root.locals.root}/modules/db/postgresql"
}

inputs = {
  name = try(local.postgresql_cfg.name, null)

  subnet_no = try(
    dependency.subnet.outputs.private_subnet_map[local.postgresql_cfg.subnet_name],
    null
  )

  user_name     = try(local.postgresql_cfg.user_name, null)
  user_password = try(local.postgresql_cfg.user_password, null)
  database_name = try(local.postgresql_cfg.database_name, null)
  host_ip       = try(local.postgresql_cfg.host_ip, null)
  port          = try(local.postgresql_cfg.port, null)

  is_ha         = try(local.postgresql_cfg.is_ha, null)
  is_multi_zone = try(local.postgresql_cfg.is_multi_zone, null)
}
