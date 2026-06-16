#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

export KKZONE=cn

helm repo add kubesphere https://charts.kubesphere.com.cn/main
helm repo update

ks_ver=${1:-latest}

opt=""
if [[ "$ks_ver" != "latest" ]]; then
  opt="--version $ks_ver"
fi
# shellcheck disable=SC2086
helm upgrade --install -n kubesphere-system --create-namespace ks-core $opt \
  oci://hub.kubesphere.com.cn/kse/ks-core