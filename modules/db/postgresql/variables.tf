variable "name" {
  description = "MySQL 서비스 이름 (Cloud DB Service Name 및 서버 접두사로 사용)"
  type        = string
}

variable "subnet_no" {
  description = "MySQL이 배치될 Private Subnet 번호"
  type        = string
}

variable "user_name" {
  description = "MySQL 관리자 계정 이름"
  type        = string
}

variable "user_password" {
  description = "MySQL 관리자 계정 비밀번호"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "초기 생성될 MySQL 데이터베이스 이름"
  type        = string
}

variable "host_ip" {
  description = "MySQL 접속을 허용할 호스트 IP (예: %, 특정 CIDR)"
  type        = string
}

variable "port" {
  description = "MySQL 접속을 사용할 포트 (예: 3306)"
  type        = number
}

variable "is_ha" {
  description = "MySQL 고가용성(HA) 구성 여부"
  type        = bool
  default     = false
}

variable "is_multi_zone" {
  description = "MySQL 멀티 존 구성 여부 (HA 사용 시에만 true)"
  type        = bool
  default     = null
}
