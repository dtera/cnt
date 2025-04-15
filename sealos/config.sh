#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2155

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
echo "Current Directory: $CD"

k8s_v="1.28.11"
helm_v="3.15.4"
cilium_v="1.15.8"
openebs_v="3.10.0"
minio_v="5.0.6"
ingress_nginx_v="1.12.1"

masters="9.135.90.159"
nodes="9.135.117.186"
port="36000" # 22
passwd="123456"

data_dir="/data"
if [[ "$1" == "gen_dir" ]]; then
  rm -rf /var/lib/docker && rm -rf /var/lib/sealos
  [ -d "$data_dir"/docker ] || mkdir -p "$data_dir"/docker
  [ -d "$data_dir"/sealos ] || mkdir -p "$data_dir"/sealos
  rm -rf "$data_dir"/docker/* "$data_dir"/sealos/*
  ln -s "$data_dir"/docker /var/lib/docker
  ln -s "$data_dir"/sealos /var/lib/sealos
fi

export PROXY_PREFIX=https://ghfast.top
export SEALOS_VERSION=$(curl -s https://api.github.com/repos/labring/sealos/releases/latest | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4)
if [[ "$SEALOS_VERSION" == "" ]]; then
  export SEALOS_VERSION=v5.0.1
fi
export CLOUD_DOMAIN=www.wx.com  # [ip].nip.io
