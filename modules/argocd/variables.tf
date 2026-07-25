variable "namespace" {
  type    = string
  default = "argocd"
}

variable "domain" {
  description = "argocd 접속 도메인"
  type        = string
}

variable "project" {
  description = "root에 있는 프로제트 이름"
  type        = string
}

variable "env" {
  description = "argocd 환경"
  type        = string
}

variable "certificate_no" {
  description = "인증서 정보"
  type        = string
}

variable "output_dir" {
  description = "yml manifest 다운로드 경로"
  type        = string
}

variable "argocd_admin_password_bcrypt" {
  description = "초기 관리자 비밀번호 bcrypt"
  type        = string
  sensitive   = true
}
