#!/usr/bin/env bash

echo '====================BEGIN install Dependency requirements===================='
yum install -y socat conntrack ebtables ipset
echo '====================END install Dependency requirements======================'

echo '=====================BEGIN  download and insall KubeKey======================'
work_dir="/data/kubesphere"

if [[ ! -d "$work_dir" ]]; then
 mkdir "$work_dir"
fi
cd "$work_dir"

export KKZONE=cn
curl -sfL https://get-kk.kubesphere.io | VERSION=v2.2.1 sh -
chmod +x kk
cp kk /usr/local/bin
echo '=====================END  download and insall KubeKey========================'

echo '=====================BEGIN  generate config file============================='
kk create config --with-kubesphere v3.3.0 # --with-kubernetes v1.22.10 
echo '=====================END  generate config file==============================='
