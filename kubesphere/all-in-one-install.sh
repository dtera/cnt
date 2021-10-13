#!/usr/bin/env bash

echo '====================BEGIN install Dependency requirements===================='
yum install -y socat conntrack ebtables ipset
echo '====================END install Dependency requirements======================'

echo '=====================BEGIN  download and insall KubeKey======================'
if [[ ! -d "/opt/kubesphere" ]]; then
 mkdir /opt/kubesphere
fi
cd /opt/kubesphere
export KKZONE=cn
curl -sfL https://get-kk.kubesphere.io | VERSION=v1.1.1 sh -
chmod +x kk
echo '=====================END  download and insall KubeKey========================'

echo '==========================BEGIN install kubesphere==========================='
hostnamectl set-hostname ks-admin
# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 36000
# iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
# iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

./kk create cluster --with-kubernetes v1.20.4 --with-kubesphere v3.1.1 -y
echo '==========================END install kubesphere============================='
