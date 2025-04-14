#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

read -r -p "Please input password of the nodes to install k8s: " passwd

# install k8s
sh "$CD"/sealos/k8s-install.sh -p "$passwd"

# install sealos cloud
sh "$CD"/sealos/install.sh

# install kubesphere
# sh "$CD"/kubesphere/install.sh

# install dependencies by helm
# sh "$CD"/sealos/helm-install-deps.sh