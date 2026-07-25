locals {
  project = "example-ncp-project"
  region  = "KR"
  zone    = "KR-1"

  site           = "public"
  ncloud_profile = "example-ncp-profile" # .aws/credential 에 설정 추가
  state_bucket   = "example-ncp-terraform-state"
}
