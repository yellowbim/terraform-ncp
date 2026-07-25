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
