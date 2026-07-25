#!/bin/bash

echo "Installing ncp-iam-authenticator..."

sudo apt-get update

curl -L \
  https://github.com/NaverCloudPlatform/ncp-iam-authenticator/releases/latest/download/ncp-iam-authenticator_linux_amd64 \
  -o $HOME/settings/ncp-iam-authenticator

chmod +x $HOME/settings/ncp-iam-authenticator

mkdir -p $HOME/bin
# mv $HOME/settings/ncp-iam-authenticator $HOME/bin/
sudo mv $HOME/settings/ncp-iam-authenticator /usr/local/bin/ncp-iam-authenticator

# grep -q 'HOME/bin' ~/.profile || echo 'export PATH=$PATH:$HOME/bin' >> ~/.profile
# export PATH=$PATH:$HOME/bin
# source ~/.profile

echo "ncp-iam-authenticator installed"
echo



######################### kubectl
echo "Installing kubectl..."

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
 | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
 | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

echo "kubectl installed"
echo "kubectl version"
kubectl version

echo
echo

######################### kubectl
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