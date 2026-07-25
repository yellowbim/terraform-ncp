# nks cluster 생성 파일
resource "ncloud_nks_cluster" "this" {
  name                = var.name
  kube_network_plugin = "cilium"
  hypervisor_code     = var.hypervisor_code
  cluster_type        = "SVR.VNKS.STAND.C004.M016.G003" # hypervisor 코드별로 사용 가능한 노드 갯수가 정해져있음
  # k8s_version         = data.ncloud_nks_versions.version.versions.0.value
  k8s_version = var.k8s_version

  login_key_name = var.login_key_name

  auth_type = "API"

  access_entries {
    # type  = "USER"
    entry = var.login_user_id

    policies {
      type  = "NKSClusterAdminPolicy" # 기본적으로 관리자 권한
      scope = "cluster"
    }
  }

  zone                 = var.zone
  vpc_no               = var.vpc_id
  subnet_no_list       = var.subnet_no_list
  lb_private_subnet_no = var.lb_private_subnet_no
  lb_public_subnet_no  = var.lb_public_subnet_no

  log {
    audit = true
  }

}
