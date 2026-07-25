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
  --output $HOME/settings/kubeconfig/kubeconfig-prod.yaml

echo "============== kubeconfig generated ====================="
echo
echo "check connection!!!!!!!!!"
echo "kubectl --kubeconfig $HOME/.kube/config get namespaces"


# kubeconfig 생성 이후
echo "============== merge origin config ====================="
export KUBECONFIG=$HOME/.kube/config:$HOME/settings/kubeconfig/kubeconfig-prod.yaml
kubectl config view --merge --flatten > /tmp/merged-config

# 백업
cp $HOME/.kube/config $HOME/.kube/config.bak.$(date +%Y%m%d%H%M%S)

# 교체
mv /tmp/merged-config $HOME/.kube/config
chmod 600 $HOME/.kube/config

echo "merge completed"



echo "============== change context name to prod ====================="
export KUBECONFIG=$HOME/.kube/config
CURRENT_CONTEXT=$(kubectl config get-contexts -o name | tail -n 1) # 가장 마지막에 들어온 context
NEW_CONTEXT="prod"

kubectl config rename-context "$CURRENT_CONTEXT" "$NEW_CONTEXT"
kubectl config get-contexts