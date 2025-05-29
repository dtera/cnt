#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2155

k8s_v="1.28.11"
helm_v="3.15.4"
cilium_v="1.15.8"
openebs_v="3.10.0"
minio_v="5.0.6"
ingress_nginx_v="1.12.1"

masters="127.0.0.1" # comma seperated
nodes="127.0.0.1" # comma seperated
port="36000" # 22
passwd="123456"

export PROXY_PREFIX=https://ghfast.top
export SEALOS_VERSION=$(curl -s https://api.github.com/repos/labring/sealos/releases/latest | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4)
if [[ "$SEALOS_VERSION" == "" ]]; then
  export SEALOS_VERSION=v5.0.1
fi
export CLOUD_DOMAIN=www.wx.com  # [ip].nip.io
