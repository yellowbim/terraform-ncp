locals {
  selected_project = get_env("TG_PROJECT")
  selected_env     = get_env("TG_ENV")
  project_cfg      = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/project.hcl")
  env_cfg          = read_terragrunt_config("${get_repo_root()}/projects/${local.selected_project}/${local.selected_env}.hcl")
  output_dir       = "${get_repo_root()}/projects/${local.selected_project}/_generated/${local.selected_env}/category/server-images"
}

# 이거 image.json 파일은 정상적으로 만들긴 함
# 근데 이걸 사용해서 스펙이랑 연동해서 써야하는데 일단은 미사용
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
  source = "${include.root.locals.root}/modules/category/server-images"

  before_hook "prepare_output_dir" {
    commands = get_terraform_commands_that_need_vars()
    execute  = ["sh", "-c", "mkdir -p '${local.output_dir}'"]
  }
}

inputs = {
  output_dir = local.output_dir
}
