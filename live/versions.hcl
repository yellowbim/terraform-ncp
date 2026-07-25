generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  terraform {
    required_version = ">= 1.5.0"

    required_providers {
      kubectl = {
        source  = "gavinbunney/kubectl"
        version = "~> 1.14"
      }
      ncloud = {
        source  = "navercloudplatform/ncloud"
        version = "> 4.0"
      }
    }
  }
EOF
}
