#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2088
# shellcheck disable=SC2154

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

conf_file="ks-config.yml"

echo '====================BEGIN install Dependency requirements===================='
yum install -y socat conntrack ebtables ipset
echo '====================END install Dependency requirements======================'

echo '=====================BEGIN  download and install KubeKey====================='
work_dir="/data/workspace/kubesphere"
if [[ ! -d "$work_dir" ]]; then
 mkdir -p "$work_dir"
fi
# shellcheck disable=SC2164
cd "$work_dir"

export KKZONE=cn

curl -sfL https://get-kk.kubesphere.io | sh -
chmod +x kk
mv kk /usr/local/bin
echo '=====================END  download and install KubeKey======================='

echo '=====================BEGIN  generate config file============================='
kk create config -f "$conf_file"
echo '=====================END  generate config file==============================='

# kk create cluster -f "$conf_file"