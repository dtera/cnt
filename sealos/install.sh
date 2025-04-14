#!/usr/bin/env bash

# shellcheck disable=SC2181

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/config.sh


which sealos &> /dev/null
if [[ $? != 0 ]]; then
  curl -sfL ${PROXY_PREFIX}/https://raw.githubusercontent.com/labring/sealos/main/scripts/install.sh | \
  PROXY_PREFIX=${PROXY_PREFIX} sh -s ${VERSION} labring/sealos
fi

echo "PROXY_PREFIX: $PROXY_PREFIX"
echo "SEALOS_VERSION: $SEALOS_VERSION"
echo "CLOUD_DOMAIN: $CLOUD_DOMAIN"

curl -sfL $PROXY_PREFIX/https://raw.githubusercontent.com/labring/sealos/v"$SEALOS_VERSION"/scripts/cloud/install.sh \
  -o /tmp/install.sh && bash /tmp/install.sh --cloud-version=v"$SEALOS_VERSION" \
  --image-registry=registry.cn-shanghai.aliyuncs.com --zh \
  --proxy-prefix=$PROXY_PREFIX \
  --cloud-domain="$CLOUD_DOMAIN"
