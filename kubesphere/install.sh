#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

export KKZONE=cn

helm repo add kubesphere https://charts.kubesphere.com.cn/main
helm repo update

ks_ver=${1:-latest}

if [[ "$ks_ver" == "latest" ]]; then
  helm upgrade --install -n kubesphere-system --create-namespace ks-core \
    oci://hub.kubesphere.com.cn/kse/ks-core
else
  # ks_ver=1.1.4
  # 如果无法访问 charts.kubesphere.io, 可将 charts.kubesphere.io 替换为 charts.kubesphere.com.cn
  helm upgrade --install -n kubesphere-system --create-namespace ks-core \
    https://charts.kubesphere.com.cn/main/ks-core-"$ks_ver".tgz --debug --wait
fi
