terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Namespace
resource "kubectl_manifest" "namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.namespace}
EOF
}

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.2.5/manifests/install.yaml
EOT
  }
}
# ArgoCD ClusterIP to NodePort
resource "null_resource" "argocd_service_patch" {
  provisioner "local-exec" {
    command = <<EOT
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
EOT
  }

  depends_on = [null_resource.argocd_install]
}


# ArgoCD Ingress
resource "kubectl_manifest" "argocd_ingress" {
  yaml_body = templatefile(
    "${path.module}/manifests/ingress.yaml",
    {
      project        = var.project
      env            = var.env
      domain         = var.domain
      certificate_no = var.certificate_no
    }
  )

  depends_on = [null_resource.argocd_install]
}

# Admin password
resource "kubectl_manifest" "argocd_secret" {
  yaml_body = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: argocd-secret
  namespace: argocd
type: Opaque
stringData:
  admin.password: "${var.argocd_admin_password_bcrypt}"
  admin.passwordMtime: "${timestamp()}"
EOF

  depends_on = [null_resource.argocd_install]
}

# secret 변경을 통한 재시작
resource "null_resource" "argocd_restart" {
  provisioner "local-exec" {
    command = "kubectl rollout restart deploy argocd-server -n argocd"
  }

  depends_on = [kubectl_manifest.argocd_secret]
}

# insecure 설정
resource "kubectl_manifest" "argocd_cmd_params" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  namespace: argocd
data:
  server.insecure: "true"
EOF

  depends_on = [null_resource.argocd_install]
}
