#!/usr/bin/env bash

sudo apt-get update 
pip install --local awscli
sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get install -y kubectl
export PATH=$PATH:$HOME/.local/bin