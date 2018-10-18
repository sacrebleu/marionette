#!/usr/bin/env bash
export PATH=$PATH:$HOME/.local/bin

echo "Installing awscli"

pip install --user awscli
export PATH=$PATH:$HOME/.local/bin

echo "Installing kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "Installing aws-iam-authenticator"
curl -LO https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator


mkdir -p ${HOME}/.aws
cat <<-EOF > ${HOME}/.aws/config
[default]
region = ${REGION}
EOF

echo "Configuring access for ${CLUSTER_NAME}"
aws --no-verify-ssl eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}

echo "Generated kube config:"
cat ${HOME}/.kube/config

echo "Done"