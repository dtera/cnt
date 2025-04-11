#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

export KKZONE=cn

ks_ver=1.1.4
# 如果无法访问 charts.kubesphere.io, 可将 charts.kubesphere.io 替换为 charts.kubesphere.com.cn
helm upgrade --install -n kubesphere-system --create-namespace ks-core \
     https://charts.kubesphere.com.cn/main/ks-core-"$ks_ver".tgz --debug --wait