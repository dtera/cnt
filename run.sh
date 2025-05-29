#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

read -r -p "Please input ip addresses of masters to install k8s[127.0.0.1]: " masters
masters=${masters:-127.0.0.1}
read -r -p "Please input ip addresses of nodes to install k8s[127.0.0.1]: " nodes
nodes=${nodes:-127.0.0.1}
read -r -p "Please input password of the nodes to install k8s[123456]: " passwd
passwd=${passwd:-123456}

opt="--cilium"
if [[ "$1" == "seal_cloud" ]]; then
  opt=""
fi

if [[ "$masters" == "127.0.0.1" && "$masters" == "127.0.0.1" ]]; then
  opt="$opt --single"
else
  opt="$opt -m $masters -n $nodes"
fi

# install k8s
sh "$CD"/sealos/k8s-install.sh "$opt -p $passwd"

if [[ "$1" == "seal_cloud" ]]; then
  # install sealos cloud
  sh "$CD"/sealos/install.sh
else
  # install kubesphere
  sh "$CD"/kubesphere/install.sh

  # install dependencies by helm
  sh "$CD"/sealos/helm-install-deps.sh
fi
