#!/usr/bin/env bash

sh ./kk-config.sh

echo '==========================BEGIN install kubesphere==========================='
hostnamectl set-hostname ks-admin
# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 36000
# iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
# iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

arg=""
if [ "$1" != "" ]; then
  arg=$1
fi

./kk create cluster --with-kubesphere v3.3.0 "$arg" # --with-kubernetes v1.22.10 
echo '==========================END install kubesphere============================='
