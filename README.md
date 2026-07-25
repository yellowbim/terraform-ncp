# terraform-ncp

Naver Cloud Platform 인프라를 Terraform과 Terragrunt로 구성한 포트폴리오용 IaC 예제입니다.

이 저장소는 실제 운영/회사 환경의 값이 아닌 샘플 값을 사용합니다. access key, secret key, 비밀번호, 실제 도메인, 실제 IP, 계정 NRN, 인증서 번호, PEM 파일, Terraform state는 포함하지 않습니다.

## Architecture

```text
Internet
  |
Public Subnet
  |-- Bastion
  |-- Public Load Balancer Subnet
  |-- NAT Gateway
        |
Private Subnet
  |-- NKS Node Pool
  |-- Cloud DB
  |-- Private Load Balancer Subnet

Object Storage
  |-- Terraform Remote State

NKS
  |-- Argo CD
```

## What This Builds

- VPC
- Public and private subnets
- NAT Gateway
- Route table
- Access Control Group
- Bastion server
- SSH login key
- Init script
- NKS cluster
- NKS node pool
- NKS ACG rule
- Cloud DB for MySQL/PostgreSQL
- Object Storage bucket
- Argo CD on NKS
- NCP catalog data lookup modules for server images, server specs, NKS images, and NKS versions

## Design Decisions

### Public And Private Network Separation

외부 접근이 필요한 리소스와 직접 노출되면 안 되는 리소스를 분리하기 위해 public/private subnet 구조를 사용했습니다.

Bastion과 NAT Gateway는 public subnet에 배치하고, NKS node와 DB는 private subnet에 배치합니다. 이 구조는 운영 접근 경로를 제한하면서도 private 리소스가 패키지 설치, 이미지 pull, 업데이트 등을 위해 outbound 통신을 할 수 있게 합니다.

### Terragrunt Based Environment Management

Terraform 모듈은 재사용 가능한 리소스 단위로 유지하고, Terragrunt에서 프로젝트/환경별 입력값과 backend/provider 생성을 관리합니다.

`TG_PROJECT`, `TG_ENV` 환경 변수를 기준으로 프로젝트와 환경을 선택하고, 모듈 경로에 따라 Terraform state key를 일관되게 생성합니다.

### Remote State On Object Storage

NCP Object Storage의 S3-compatible API를 Terraform backend로 사용합니다.

로컬 state 파일에 의존하지 않고 Object Storage에 state를 저장하면, 환경별 state를 분리하고 여러 모듈의 적용 순서를 관리하기 쉽습니다.

### Layered Execution

인프라 의존성을 명확히 하기 위해 아래 순서로 적용합니다.

1. network
2. cert
3. compute/init-script
4. compute/bastion
5. nks/cluster
6. nks/node
7. db
8. storage
9. argocd

## Repository Structure

```text
.
├── live
│   ├── root.hcl
│   ├── provider.hcl
│   ├── backend.hcl
│   └── stack
├── modules
│   ├── network
│   ├── compute
│   ├── cert
│   ├── nks
│   ├── db
│   ├── storage
│   └── argocd
├── projects
│   └── example-ncp-project
└── provisoning
    └── bastion
```

## Configuration

공개 저장소에서는 실제 값 대신 아래와 같은 placeholder를 사용합니다.

```hcl
project        = "example-ncp-project"
ncloud_profile = "example-ncp-profile"
state_bucket   = "example-ncp-terraform-state"
domain         = "argocd.example.com"
certificate_no = "<CERTIFICATE_NO>"
login_user_id  = "<NCP_SUBACCOUNT_NRN>"
```

```bash
export TG_PROJECT=example-ncp-project
export TG_ENV=dev
export NCLOUD_ACCESS_KEY=<NCP_ACCESS_KEY>
export NCLOUD_SECRET_KEY=<NCP_SECRET_KEY>
```

## Security Notes

이 저장소에는 다음 항목을 커밋하지 않습니다.

- NCP access key / secret key
- DB password
- Argo CD admin password hash
- PEM private key
- 실제 도메인
- 실제 IP allowlist
- 실제 SubAccount NRN
- Terraform state
- `.terraform`
- `.terragrunt-cache`

## Status

현재 README는 포트폴리오 공개용 초안입니다. 실제 원본 Terraform 구성은 공개용 샘플 값으로 정리한 뒤 이 저장소로 이관합니다.
