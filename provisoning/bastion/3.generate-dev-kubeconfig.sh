#!/bin/bash

# 값 입력
read -p "민간/공공 구분 (PUBLIC | GOV) : " SITE
read -p "NCLOUD ACCESS KEY: " ACCESS_KEY
read -s -p "NCLOUD SECRET KEY: " SECRET_KEY
echo
read -p "CLUSTER UUID: " CLUSTER_UUID
echo

# 사이트 분리
case "$SITE" in
  PUBLIC|public)
    NCLOUD_API_URL="https://ncloud.apigw.ntruss.com"
    ;;
  GOV|gov)
    NCLOUD_API_URL="https://ncloud.apigw.gov-ntruss.com"
    ;;
  *)
    echo "SITE 값은 PUBLIC 또는 GOV 만 가능합니다."
    exit 1
    ;;
esac


mkdir -p ~/.ncloud
mkdir -p ~/.kube

cat <<EOF > ~/.ncloud/configure
[DEFAULT]
ncloud_access_key_id = $ACCESS_KEY
ncloud_secret_access_key = $SECRET_KEY
ncloud_api_url = $NCLOUD_API_URL
EOF

# kubeconfig 생성
ncp-iam-authenticator create-kubeconfig \
  --region KR \
  --clusterUuid $CLUSTER_UUID \
  --output $HOME/settings/kubeconfig/kubeconfig-dev.yaml

cp $HOME/settings/kubeconfig/kubeconfig-dev.yaml $HOME/.kube/config

echo "kubeconfig generated"
echo
echo "check connection!!!!!!!!!"
echo "kubectl --kubeconfig $HOME/.kube/config get namespaces"


# kubeconfig 생성 이후
export KUBECONFIG=$HOME/.kube/config
CURRENT_CONTEXT=$(kubectl config current-context)
NEW_CONTEXT="dev"   # ← 아예 자동화하면 read 안 받아도 됨
kubectl config rename-context "$CURRENT_CONTEXT" "$NEW_CONTEXT"
kubectl config get-contexts


echo
echo

### kubie 설치
echo "Installing kubie..."

wget https://github.com/sbstp/kubie/releases/latest/download/kubie-linux-amd64 -O kubie
chmod +x kubie
sudo mv kubie /usr/local/bin/

echo "kubie installed"
