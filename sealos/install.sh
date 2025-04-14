#!/usr/bin/env bash

# shellcheck disable=SC2181

set -x

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
source "$CD"/config.sh

echo "PROXY_PREFIX: $PROXY_PREFIX"
echo "SEALOS_VERSION: $SEALOS_VERSION"
echo "CLOUD_DOMAIN: $CLOUD_DOMAIN"

curl -sfL $PROXY_PREFIX/https://raw.githubusercontent.com/labring/sealos/v"$SEALOS_VERSION"/scripts/cloud/install.sh \
  -o /tmp/install.sh && bash /tmp/install.sh --cloud-version=v"$SEALOS_VERSION" \
  --image-registry=registry.cn-shanghai.aliyuncs.com --zh \
  --proxy-prefix=$PROXY_PREFIX \
  --cloud-domain="$CLOUD_DOMAIN"
