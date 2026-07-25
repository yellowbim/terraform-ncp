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


dependency "nks_node" {
  config_path = "../../infra/nks/node"
}


terraform {
  source = "${include.root.locals.root}/modules/argocd"
}

inputs = {
  namespace                    = local.env_cfg.locals.argocd.namespace
  project                      = include.root.locals.project
  env                          = local.env_cfg.locals.argocd.env
  domain                       = local.env_cfg.locals.argocd.domain
  certificate_no               = local.env_cfg.locals.argocd.certificate_no
  output_dir                   = get_terragrunt_dir()
  argocd_admin_password_bcrypt = local.env_cfg.locals.argocd.argocd_admin_password_bcrypt
}
