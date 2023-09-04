#!/usr/bin/env bash

echo '==========================BEGIN install kubesphere==========================='
export KKZONE=cn
#hostnamectl set-hostname ks-admin
# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 36000
# iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

arg=$*
if [ "$arg" == "" ]; then
  arg="-f ks-config.yml"
fi

[ "$1" == "config" ] && (which kk || sh ./kk-config.sh) && arg=${arg:6} && (shift 1)
[ "$1" == "allinone" ] && arg=""

kk create cluster --with-kubesphere v3.4.0 $arg # --with-kubernetes v1.22.12
echo '==========================END install kubesphere============================='
