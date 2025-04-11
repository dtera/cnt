#!/usr/bin/env bash

# shellcheck disable=SC2154

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/config.sh

which sealos &> /dev/null
# shellcheck disable=SC2181
if [[ $? != 0 ]]; then
  export PROXY_PREFIX=https://ghfast.top
  VERSION=$(curl -s https://api.github.com/repos/labring/sealos/releases/latest | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4)
  curl -sfL ${PROXY_PREFIX}/https://raw.githubusercontent.com/labring/sealos/main/scripts/install.sh | \
  PROXY_PREFIX=${PROXY_PREFIX} sh -s ${VERSION} labring/sealos
fi

opt="--masters $masters --nodes $nodes"
if [[ "$1" == "single" ]]; then
  opt="--single"
fi
sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v"$k8s_v" \
           registry.cn-shanghai.aliyuncs.com/labring/helm:v"$helm_v" \
           registry.cn-shanghai.aliyuncs.com/labring/cilium:v"$cilium_v" \
           registry.cn-shanghai.aliyuncs.com/labring/openebs:v"$openebs_v" \
           registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v"$minio_v" \
           registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v"$ingress_nginx_v" \
           $opt --port $port -p $passwd

kubectl taint node admin node-role.kubernetes.io/control-plane:NoSchedule-
kubectl label nodes admin node-role.kubernetes.io/master= node-role.kubernetes.io/worker=