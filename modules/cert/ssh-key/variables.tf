# 입력 파일
variable "key_name" {
  description = "SSH login key name"
  type        = string
}

variable "output_dir" {
  description = "SSH 키파일 다운로드 경로"
  type        = string
}