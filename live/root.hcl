locals {
  root             = get_repo_root()
  selected_project = get_env("TG_PROJECT")
  selected_env     = get_env("TG_ENV")
  project_cfg      = read_terragrunt_config("${local.root}/projects/${local.selected_project}/project.hcl")

  project        = local.project_cfg.locals.project
  region         = local.project_cfg.locals.region
  zone           = local.project_cfg.locals.zone
  site           = local.project_cfg.locals.site
  ncloud_profile = local.project_cfg.locals.ncloud_profile
  state_bucket   = local.project_cfg.locals.state_bucket
  ncloud_access_key = trimspace(get_env("NCLOUD_ACCESS_KEY", "")) != "" ? trimspace(get_env("NCLOUD_ACCESS_KEY", "")) : trimspace(run_cmd(
    "--terragrunt-quiet",
    "aws",
    "configure",
    "get",
    "aws_access_key_id",
    "--profile",
    local.ncloud_profile
  ))
  ncloud_secret_key = trimspace(get_env("NCLOUD_SECRET_KEY", "")) != "" ? trimspace(get_env("NCLOUD_SECRET_KEY", "")) : trimspace(run_cmd(
    "--terragrunt-quiet",
    "aws",
    "configure",
    "get",
    "aws_secret_access_key",
    "--profile",
    local.ncloud_profile
  ))

  site_endpoints = {
    public = {
      object_storage = "https://kr.object.ncloudstorage.com"
      api_base       = "https://api.ncloud.com"
      monitoring     = "https://monitoring.ncloud.com"
    }
    gov = {
      object_storage = "https://kr.object.gov-ncloudstorage.com"
      api_base       = "https://api.gov-ncloud.com"
      monitoring     = "https://monitoring.gov-ncloud.com"
    }
  }
  endpoints = local.site_endpoints[local.site]
}

terraform {
  extra_arguments "ncloud_auth_from_profile" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      NCLOUD_ACCESS_KEY = local.ncloud_access_key
      NCLOUD_SECRET_KEY = local.ncloud_secret_key
    }
  }
}
