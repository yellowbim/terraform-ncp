## 🚀 Terraform / Terragrunt 사용 가이드 (DevOps Team)
## 📌 문서 목적
이 가이드는 DevOps 팀원이 신규 프로젝트 또는 신규 환경(dev / stg / prod)을 Terraform + Terragrunt 기반으로 구성할 수 있도록 작성되었습니다.

<br/><br/>

## 🧭 IaC 구조 개념

```
Project
 ├ dev
 │   ├ infra
 │   │   ├ network
 │   │   ├ cert
 │   │   ├ compute
 │   │   ├ nks
 │   │   ├ db
 │   │   └ argocd
 ├ stg
 └ prod
```
<br/><br/>

## 전체 구성 개념
Terraform / Terragrunt 기반 IaC 구성은 다음 Layer로 나뉩니다.

### Infrastructure Layer
- VPC  
- Subnet  
- Route Table  
- NAT Gateway  
- Bastion  


### Platform Layer
- NKS Cluster  
- Node Pool  
- ACG  


### Service Layer
- Database (MySQL / PostgreSQL)  
- Object Storage  
- ArgoCD  
- 기타 서비스 리소스 


<br/><br/>
## 🔄 IaC 실행 흐름

Terraform 실행은 **의존성 순서 기반**으로 수행해야 합니다.

### 실행 순서
```
network
↓
cert
↓
compute/init-script
↓
compute (bastion)
↓
nks
↓
db
↓
argocd (옵션)
```

<br/><br/>

## terraform, terragrunt 환경 구축
### mac (home brew)
```bash
# terraform 설치
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

terraform version

# terragrunt 설치
brew install terragrunt
terragrunt --version

# tvenv 테라폼 버전 관리
brew install tfenv

# zshrc 파일추가
`
eval "$(/opt/homebrew/bin/brew shellenv)"
`

brew unlink terraform
brew link terraform

tfenv --version

# 버전 생성 (이건 복붙할거라 안써도 됨)
# echo "1.6.6" > .terraform-version

```

### window
```bash
# powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco --version

# terraform
choco install terraform -y
terraform version

# terragrunt
choco install terragrunt -y
terragrunt --version
```
<br/><br/>


## 신규 프로젝트 생성
### STEP 0 — Credential 설정
1. object storage 업로드를 위한 aws 설정

    프로젝트 이름은 root.hcl - ncloud_profile 이름이랑 동일하게 맞춰야함
    ```bash
    vi ~/.aws/credentials
    [example-ncp-project-dev] 
    aws_access_key_id = <NCP_IAM_KEY>
    aws_secret_access_key = <NCP_IAM_KEY>
    ```

2. ncloud 로컬 환경변수 등록
    ncp provider의 경우 profile 지원을 하지 않음.... (aws 대비 너무 안되는게 많다...ㅂㄷㅂㄷ)
    ```bash
    # 쉘 단위 환경변수 설정
    export NCLOUD_ACCESS_KEY=<NCP_IAM_KEY>
    export NCLOUD_SECRET_KEY=<NCP_IAM_KEY>
    ```

### STEP 1 — 템플릿 복사
- tf-template 폴더를 복사해서 새로운 프로젝트로 생성


### STEP 2 — root.hcl 수정
- root.hcl 은 프로젝트 전체에서 사용하는 **전역 설정 파일**입니다.  
  (shared network / shared resource 사용 여부 포함)

    | 항목                   | 설명                                      | ---  |
    | ---------------------- | ----------------------------------------- | ---- |
    | project                | 프로젝트 이름                             | 필수 |
    | region                 | KR                                        | 필수 |
    | zone                   | KR-1                                      | 필수 |
    | site                   | public / gov                              | 필수 |
    | ncloud_profile         | object storage profile                    | 필수 |
    |                        |                                           |      |
    | bastion_defaults       | bastion 접속 계정 설정                    | 옵션 |
    | bastion_defaults       | Bastion 기본 접속 계정                    | 옵션 |
    | shared_network_project | Shared Network 프로젝트명 (사용 시)       | 옵션 |
    | shared_network_env     | Shared Network 환경 (dev / stg / prod 등) | 옵션 |

<br/>
Shared Network 사용하는 경우

현재 IaC 구조에서는 아래와 같이 구성 가능합니다.

```
Shared Project
 ├ shared
 │   ├ network
 │   ├ nat
 │   ├ subnet
 │   └ route-table

Service Project
 ├ dev
 ├ stg
 ├ prod
```





- env.hcl 파일 수정

    | 항목             | 설명                                   | ---  |
    | ---------------- | -------------------------------------- | ---- |
    | env              | dev / stg / prod                       | 필수 |
    | layers           | vpc, bastion 공용으로 쓸지 여부        | 필수 |
    | zone             | KR-1                                   | 필수 |
    | site             | public / gov                           | 필수 |
    | ncloud_profile   | object storage profile                 | 필수 |
    | bastion_defaults | bastion 접속 계정 설정                 | 옵션 |
    | vpc_default      | VPC를 dev/stg/prod 같이 쓰는 경우 설정 | 옵션 |



### 3. tf state 관리를 위한 object storage 설정
- 초기 bootstrap 설정을 별도로 넣어놓지 않았기 때문에 **상태관리를 위한 object storage 를 수동으로 생성**해줘야함
  - object storage 이름 : env.hcl > state_bucket

### 4. terraform 실행
- 아래와같은 폴더 진입 후 순서대로 실행
  1. network
  2. cert
  3. compute > init script
  4. compute
  5. nks
  6. db
  7. argocd (옵션)

    ex) example-ncp-project > dev > infra > network
    ```bash
    terragrunt run --all apply
    yes

    ### 실행 결과
    yes
    13:28:04.483 STDOUT terraform: ncloud_vpc.this: Creating...
    13:28:14.494 STDOUT terraform: ncloud_vpc.this: Still creating... [10s elapsed]
    13:28:15.479 STDOUT terraform: ncloud_vpc.this: Creation complete after 11s [id=133394]
    13:28:15.484 STDOUT terraform: ncloud_route_table.this["tf-dev-pri-nat-rt"]: Creating...
    13:28:15.486 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-nat-a"]: Creating...
    13:28:15.486 STDOUT terraform: ncloud_subnet.this["tf-dev-pri-lb-a"]: Creating...
    13:28:15.486 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-a"]: Creating...
    13:28:15.486 STDOUT terraform: ncloud_subnet.this["tf-dev-pri-a"]: Creating...
    13:28:15.487 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-lb-a"]: Creating...
    13:28:20.123 STDOUT terraform: ncloud_route_table.this["tf-dev-pri-nat-rt"]: Creation complete after 5s [id=278551]
    13:28:23.154 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-nat-a"]: Creation complete after 8s [id=286864]
    13:28:23.201 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-lb-a"]: Creation complete after 8s [id=286865]
    13:28:23.532 STDOUT terraform: ncloud_subnet.this["tf-dev-pri-a"]: Creation complete after 9s [id=286866]
    13:28:23.540 STDOUT terraform: ncloud_subnet.this["tf-dev-pub-a"]: Creation complete after 9s [id=286867]
    13:28:23.747 STDOUT terraform: ncloud_subnet.this["tf-dev-pri-lb-a"]: Creation complete after 9s [id=286868]
    13:28:23.752 STDOUT terraform: ncloud_route_table_association.this["tf-dev-pri-nat-rt-tf-dev-pri-lb-a"]: Creating...
    13:28:23.756 STDOUT terraform: ncloud_route_table_association.this["tf-dev-pri-nat-rt-tf-dev-pri-a"]: Creating...
    13:28:23.757 STDOUT terraform: ncloud_nat_gateway.this[0]: Creating...
    13:28:29.854 STDOUT terraform: ncloud_route_table_association.this["tf-dev-pri-nat-rt-tf-dev-pri-a"]: Creation complete after 6s [id=278551:286866]
    13:28:29.854 STDOUT terraform: ncloud_route_table_association.this["tf-dev-pri-nat-rt-tf-dev-pri-lb-a"]: Creation complete after 6s [id=278551:286868]
    13:28:33.758 STDOUT terraform: ncloud_nat_gateway.this[0]: Still creating... [10s elapsed]
    13:28:43.758 STDOUT terraform: ncloud_nat_gateway.this[0]: Still creating... [20s elapsed]
    13:28:53.758 STDOUT terraform: ncloud_nat_gateway.this[0]: Still creating... [30s elapsed]
    13:29:00.530 STDOUT terraform: ncloud_nat_gateway.this[0]: Creation complete after 37s [id=127613405]
    13:29:00.650 STDOUT terraform: ncloud_route.nat["tf-dev-pri-nat-rt"]: Creating...
    13:29:10.651 STDOUT terraform: ncloud_route.nat["tf-dev-pri-nat-rt"]: Still creating... [10s elapsed]
    13:29:20.652 STDOUT terraform: ncloud_route.nat["tf-dev-pri-nat-rt"]: Still creating... [20s elapsed]
    13:29:28.279 STDOUT terraform: ncloud_route.nat["tf-dev-pri-nat-rt"]: Creation complete after 27s [id=route-3354270180]
    13:29:28.330 STDOUT terraform: 
    13:29:28.330 STDOUT terraform: Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
    13:29:28.330 STDOUT terraform: 
    13:29:28.330 STDOUT terraform: Outputs:
    13:29:28.330 STDOUT terraform: 
    13:29:28.330 STDOUT terraform: nat_gateway_no = "127613405"
    13:29:28.330 STDOUT terraform: subnet_ids = {
    13:29:28.330 STDOUT terraform:   "tf-dev-pri-a" = "286866"
    13:29:28.330 STDOUT terraform:   "tf-dev-pri-lb-a" = "286868"
    13:29:28.330 STDOUT terraform:   "tf-dev-pub-a" = "286867"
    13:29:28.330 STDOUT terraform:   "tf-dev-pub-lb-a" = "286865"
    13:29:28.330 STDOUT terraform:   "tf-dev-pub-nat-a" = "286864"
    13:29:28.330 STDOUT terraform: }
    13:29:28.330 STDOUT terraform: vpc_no = "133394"
    ```

  * ArgoCD의 경우 현재 실행중인 쉘 context를 따라감!!!!!
    무조건 로컬 환경을 잘 확인하고 실행해야됨!!!!!!
        
    1. kubeconfig 복사
      로컬 .kube/config 파일에 cluster 추가
      ```bash
      # 1. 기존 파일 백업
      cp ~/.kube/config ~/.kube/config.bak

      # 2. 신규 설정 추가 (<b>옮길 파일 위치</b> 잘 봐야함. 에러나면 앞에 파일은 유지됨)
      KUBECONFIG=~/.kube/config:./tf-test-config.yaml kubectl config view --merge --flatten > ~/.kube/config.tmp

      # 3. 정상 확인 후 교체
      cat ~/.kubeconfig.tmp
      mv ~/.kube/config.tmp ~/.kube/config



      # 기존 config 파일에 삭제하고싶을때 (기존 정보 알고있어야함)
      kubectl config delete-context <NAME>
      kubectl config delete-cluster <cluster-name>
      kubectl config delete-user <user-name>

      kubectl config view -o jsonpath='{.clusters[*].name}'
      kubectl config view -o jsonpath='{.users[*].name}'
      ```

    2. context 설정
      ```bash
      # context 이름 변경
      kubectl config rename-context <NAME> <바꿀 이름>

      # config에 있는 cluster 정보 조회
      kubectl config get-contexts

      # context 변경
      kubectl config use-context <NAME>

      # 현재 context 조회
      kubectl config current-context
      ```

    3. ncloud 설정 등록
      vi ~/.ncloud/config
      -> 아래와같이 프로젝트 이름별로 설정
      ```bash
      [DEFAULT]
      ncloud_access_key_id = <NCP_IAM_KEY>
      ncloud_secret_access_key = <NCP_IAM_KEY>
      ncloud_api_url = https://ncloud.apigw.gov-ntruss.com

      [tf-pub]
      ncloud_access_key_id = <NCP_IAM_KEY>
      ncloud_secret_access_key = <NCP_IAM_KEY>
      ncloud_api_url = https://ncloud.apigw.ntruss.com
      ```

      사용할 환경 셋팅 및 조회
      ```bash
      export NCLOUD_PROFILE=tf-pub
      kubectl get ns
      ```

    4. ArgoCD 관리자 비밀번호 설정
       ArgoCD 는 평문으로 값을 넣으면 안됨. 그래서 로컬에서 평문 -> bcrypt 변환 작업을 해서 넣어줘야함
       ```bash
       htpasswd -nbBC 10 "" 비밀번호
       :$2y$10$3axrjphRIgNRD8aF9FZL7.fOnOGzHzP0z42UJeGE9MNSAYU1Pq3vi
       ```

       맥북이라 그런지 모르겠는데 앞에 ":"가 붙음. **"." 무조건 빼고 넣어야함!!!!!!!!!!!**
       

<br/><br/><br/>

# Bastion 서버 셋팅
1. 기본 폴더 셋팅
    ```bash
    mkdir -p $HOME/settings/provisoning
    ```

2. provisoning > bastion 아래에 있는 실행파일 실행

   - **4번은 운영서버 진행할때만 실행**


<br/><br/><br/>

# 부록
#### 기타 명령어
```bash
# 특정 파일 수정 후 샘플 테스트
terragrunt plan

# 전체 파일 실행
terragrunt run --all apply

# 특정 파일 실행
terragrunt run apply

# 특정 설정 삭제
terragrunt destroy

# 전체 설정 삭제
terragrunt destroy

# 현재 폴더 아래에 모든 캐시 삭제
## 캐시는 module 기능을 수정 한 경우 사용
find . -name ".terragrunt*" -exec rm -rf {} +
find . -name ".terraform*" -exec rm -rf {} +

# backend.tf 와같은 설정파일 변경된경우 (state 경로를 설정하기때문에 다시 해줘야함)
# 기존 데이터 migrate
terragrunt init -migrate-state

# 신규 생성
terragrunt init -reconfigure
```
