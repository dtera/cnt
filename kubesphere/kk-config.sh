#!/usr/bin/env bash

echo '====================BEGIN install Dependency requirements===================='
yum install -y socat conntrack ebtables ipset
echo '====================END install Dependency requirements======================'

echo '=====================BEGIN  download and install KubeKey======================'
work_dir="/data/kubesphere"

if [[ ! -d "$work_dir" ]]; then
 mkdir "$work_dir"
fi
# shellcheck disable=SC2164
cd "$work_dir"

export KKZONE=cn
curl -sfL https://get-kk.kubesphere.io | VERSION=v3.0.7 sh -
chmod +x kk
cp kk /usr/local/bin
echo '=====================END  download and install KubeKey========================'

echo '=====================BEGIN  generate config file============================='
kk create config --with-kubesphere v3.3.2 # --with-kubernetes v1.22.12
echo '=====================END  generate config file==============================='
