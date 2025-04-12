#!/bin/bash

export PROXY_PREFIX=https://ghfast.top
export SEALOS_VERSION=5.0.1
export CLOUD_DOMAIN=www.wx.com  # [ip].nip.io

[ -f /usr/bin/sealos ] || (wget https://github.com/labring/sealos/releases/download/v"$SEALOS_VERSION"/sealos_"$SEALOS_VERSION"_linux_amd64.rpm && yum install ./sealos_"$SEALOS_VERSION"_linux_amd64.rpm)

curl -sfL "$PROXY_PREFIX"/https://raw.githubusercontent.com/labring/sealos/v"$SEALOS_VERSION"/scripts/cloud/install.sh -o /tmp/install.sh  && \
bash /tmp/install.sh   --cloud-version=v"$SEALOS_VERSION"   \
--image-registry=registry.cn-shanghai.aliyuncs.com --zh   \
--proxy-prefix="$PROXY_PREFIX" \
--cloud-domain="$CLOUD_DOMAIN"
