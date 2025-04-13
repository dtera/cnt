#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit


# install k8s
sh "$CD"/sealos/k8s-install.sh

# install kubesphere
sh "$CD"/kubesphere/install.sh

# install dependencies by helm
sh "$CD"/sealos/helm-install-deps.sh