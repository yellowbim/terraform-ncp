locals {
  env = "dev"
  ############################## 실제 변경 영역 #############################
  enable_mysql      = true
  enable_postgresql = true

  ############################## VPC #############################
  # 같은 name/cidr VPC가 있으면 재사용, 없으면 생성
  vpc = {
    name = "tf-dev-vpc-b"
    cidr = "10.30.0.0/16"
  }

  ############################## subnets #############################
  subnets = {
    public = [
      {
        name       = "tf-dev-pub-b"
        cidr       = "10.30.6.0/24"
        zone       = "KR-1"
        usage_type = "GEN"
      },
      {
        name       = "tf-dev-pub-nat-b"
        cidr       = "10.30.7.0/24"
        zone       = "KR-1"
        usage_type = "NATGW"
      },
      {
        name       = "tf-dev-pub-lb-b"
        cidr       = "10.30.8.0/24"
        zone       = "KR-1"
        usage_type = "LOADB"
      }
    ]

    private = [
      {
        name       = "tf-dev-pri-b"
        cidr       = "10.30.9.0/24"
        zone       = "KR-1"
        usage_type = "GEN"
      },
      {
        name       = "tf-dev-pri-lb-b"
        cidr       = "10.30.10.0/24"
        zone       = "KR-1"
        usage_type = "LOADB"
      }
    ]
  }

  ############################## nat gateway #############################
  nat_gateway = [
    {
      name = "tf-dev-nat-gw-b"
      zone = "KR-1"

      # 어떤 public subnet에 붙일지 인덱스
      subnet_name = "tf-dev-pub-nat-b"
    }
  ]

  ############################## route table #############################
  route_tables = [
    {
      name = "tf-dev-pri-nat-b-rt"

      target_name = "tf-dev-nat-b-gw"
      target_type = "NATGW"

      # 어떤 private subnet들을 연결할지 (이름 기준)
      subnet_names = [
        "tf-dev-pri-lb-b",
        "tf-dev-pri-b"
      ]

      subnet_type = "PRIVATE"
    }
  ]

  ############################## ssh pem #############################
  ssh_key = {
    name = "example-ncp-login-key"
  }

  ############################### init script #############################
  init_script = {
    init_script_name = "tf-init-script"
    init_script_desc = "common linux bootstrap"
    init_script_path = "init-base.sh.tpl"

    admin_user     = "terraform"
    admin_password = "<ADMIN_PASSWORD>"
    prom_password  = "<PASSWORD>"
  }

  ############################### acg #############################
  acgs = {
    bastion = {
      name        = "tf-dev-bastion-acg-b"
      description = "Bastion access control group-b"

      inbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "203.0.113.10/32"
          port_range  = "1-65535"
          description = "SSH from sample admin IP"
        }
      ]

      outbound_rules = [
        {
          protocol    = "TCP"
          ip_block    = "0.0.0.0/0"
          port_range  = "1-65535"
          description = "Outbound all"
        }
      ]
    }
  }


  ############################### 이미지 목록, 서버 목록 조회 필요!!!!!! #############################

  ############################## bastion #############################
  bastion = {
    name        = "tf-dev-bastion-b"
    subnet_name = "tf-dev-pub-b"

    # bastion 최소사양 (ubuntu24-04)
    server_image_number = 104630229 # server-images 실행 후 ubuntu 검색, "server_image_number": "104630229",
    server_spec_code    = "s2-g3a"

    login_key_name = "example-ncp-login-key"
    # init_script_name = "base-init-script-1" # 위에서 만든 init script 설정
  }


  ############################## nks 서버 목록 조회 #############################
  nks_version = {
    hypervisor_code = "KVM"
    keyword         = "1.33" # 필수 X
  }

  nks_server_images = {
    hypervisor_code = "KVM"
    keyword         = "ubuntu-22" # 필수 X
  }

  nks_server_spec = {
    software_code = "SW.VSVR.OS.LNX64.UBNTU.SVR22.WRKND.G003|23215604"
  }

  ############################## nks #############################
  nks = {
    cluster = {
      name            = "tf-dev-nks"
      hypervisor_code = "KVM"
      k8s_version     = "1.33.4-nks.2"

      login_key_name = "example-ncp-nks-key"
      login_user_id  = "<NCP_SUBACCOUNT_NRN>" # subaccount NRN

      zone                   = "KR-1"
      subnet_no_list_name    = ["tf-dev-pri-a"]
      lb_private_subnet_name = "tf-dev-pri-lb-a"
      lb_public_subnet_name  = "tf-dev-pub-lb-a"

    }

    node_pools = {
      service = {
        name        = "service-nodepool" #nks_server_spec_codes
        subnet_name = "tf-dev-pri-a"

        software_code    = "SW.VSVR.OS.LNX64.UBNTU.SVR22.WRKND.G003|23215604"
        server_spec_code = "s2-g3a"
        storage_size     = "100" # 기본값 100GB
        node_count       = 1

        # Optional
        labels = {
          role = "service"
        }

        enable_autoscaling   = true
        autoscaling_min_size = 1
        autoscaling_max_size = 1

        taints = []
      }

      # milvus = {
      #   name             = "milvus-nodepool"
      #   software_code    = "SW.VSVR.OS.LNX64.UBNTU.SVR22.WRKND.G003|23215604"
      #   server_spec_code = "s2-g3a"
      #   storage_size     = "100" # 기본값 100GB
      #   node_count       = 1

      #   # Optional
      #   labels = {
      #     role = "milvus"
      #   }

      #   enable_autoscaling   = true
      #   autoscaling_min_size = 1
      #   autoscaling_max_size = 1

      #   taints = [
      #     { key = "role", value = "milvus", effect = "NoSchedule" }
      #   ]
      # }
    }
  }

  ############################## mysql #############################
  mysql = {
    name        = "tf-dev-mysql"
    subnet_name = "tf-dev-pri-b"

    user_name     = "terraform"
    user_password = "<PASSWORD>"
    database_name = "tf_db"
    host_ip       = "%"
    port          = 3306

    is_ha         = false # 운영에서는 이 값을 true로 변경해야함
    is_multi_zone = null  # ha true일대만 멀티존 사용 가능
  }

  ############################## postgresql #############################
  postgresql = {
    name        = "tf-dev-postgresql"
    subnet_name = "tf-dev-pri-b"

    user_name     = "terraform"
    user_password = "<PASSWORD>"
    database_name = "tf_db"
    host_ip       = "%"
    port          = 5432

    is_ha         = false # 운영에서는 이 값을 true로 변경해야함
    is_multi_zone = null  # ha true일대만 멀티존 사용 가능
  }


  ############################## object storage #############################
  object_storage = {
    bucket_name = "example-ncp-object-storage"
  }


  ############################## ArgoCD #############################
  ############### 초기 비밀번호를 잘못 입력한 후 변경하려면 아래와같이 2가지로 해야함
  ############### 1. cli 로 udpate
  ############### 2. terragrunt destroy, argocd crd 삭제 후 재설치
  #######################################################################
  argocd = {
    namespace                    = "argocd"
    env                          = "dev"
    domain                       = "argocd.example.com"
    argocd_admin_password_bcrypt = "<ARGOCD_ADMIN_PASSWORD_BCRYPT>" # htpasswd -nbBC 10 "" <ADMIN_PASSWORD> 한 값을 입력
    certificate_no               = "<CERTIFICATE_NO>"
  }


}
