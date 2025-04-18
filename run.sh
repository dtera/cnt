#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

read -r -p "Please input password of the nodes to install k8s: " passwd

if [[ "$passwd" == "" ]]; then
  passwd="123456"
fi

opt="--cilium"
if [[ "$1" == "seal_cloud" ]]; then
  opt=""
fi
# install k8s
sh "$CD"/sealos/k8s-install.sh $opt -p "$passwd"

if [[ "$1" == "seal_cloud" ]]; then
  # install sealos cloud
  sh "$CD"/sealos/install.sh
else
  # install kubesphere
  sh "$CD"/kubesphere/install.sh

  # install dependencies by helm
  sh "$CD"/sealos/helm-install-deps.sh
fi


