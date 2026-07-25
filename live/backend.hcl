locals {
  root_cfg          = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  selected_project  = get_env("TG_PROJECT")
  selected_env      = get_env("TG_ENV")
  module_path       = path_relative_to_include("root")
  module_scope      = startswith(local.module_path, "global/") ? "global" : local.selected_env
  scoped_module_dir = local.module_scope == "global" ? replace(local.module_path, "global/", "") : local.module_path
  state_key         = "${local.selected_project}/${local.module_scope}/${local.scoped_module_dir}/terraform.tfstate"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      backend "s3" {
        bucket   = "${local.root_cfg.locals.state_bucket}"
        key = "${local.state_key}"
        region   = "${local.root_cfg.locals.region}"
        profile   = "${local.root_cfg.locals.ncloud_profile}"

        # To skip AWS authentication logic
        skip_region_validation      = true
        skip_requesting_account_id  = true
        skip_credentials_validation = true
        skip_metadata_api_check     = true
        skip_s3_checksum = true


        endpoints = {
        # Set the endpoint according to your region
        s3 = "${local.root_cfg.locals.endpoints.object_storage}"
      }
    }
  }
EOF
}
