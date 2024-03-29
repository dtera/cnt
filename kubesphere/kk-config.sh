#!/usr/bin/env bash
CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

echo '====================BEGIN install Dependency requirements===================='
yum install -y socat conntrack ebtables ipset
echo '====================END install Dependency requirements======================'

echo '=====================BEGIN  download and install KubeKey======================'
work_dir="/data/workspace/kubesphere"

if [[ ! -d "$work_dir" ]]; then
 mkdir -p "$work_dir"
fi
# shellcheck disable=SC2164
cd "$work_dir"

export KKZONE=cn
# shellcheck disable=SC2154
curl -sfL https://get-kk.kubesphere.io | VERSION=v"$kk_ver" sh -
chmod +x kk
cp kk /usr/local/bin
echo '=====================END  download and install KubeKey========================'

echo '=====================BEGIN  generate config file============================='
# shellcheck disable=SC2154
kk create config --with-kubesphere v"$ks_ver" # --with-kubernetes v"$k8s_ver"
echo '=====================END  generate config file==============================='
