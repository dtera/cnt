#!/bin/bash

export PROXY_PREFIX=https://ghfast.top
export SEALOS_VERSION=v5.0.1
export CLOUD_DOMAIN=www.wx.com  # [ip].nip.io

curl -sfL "$PROXY_PREFIX"/https://raw.githubusercontent.com/labring/sealos/"$SEALOS_VERSION"/scripts/cloud/install.sh -o /tmp/install.sh  && \
bash /tmp/install.sh   --cloud-version="$SEALOS_VERSION"   \
--image-registry=registry.cn-shanghai.aliyuncs.com --zh   \
--proxy-prefix=$PROXY_PREFIX \
--cloud-domain="$CLOUD_DOMAIN"
