locals {
  root_cfg = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  provider "ncloud" {
    support_vpc = true
    region = "${local.root_cfg.locals.region}"
    site   = "${local.root_cfg.locals.site}"
  }
  provider "kubectl" {
    config_path = "~/.kube/config"
  }
EOF
}
