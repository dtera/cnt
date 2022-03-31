#!/usr/bin/env bash

sh ./kk-config.sh

echo '==========================BEGIN install kubesphere==========================='
hostnamectl set-hostname ks-admin
# iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22 -j REDIRECT --to-ports 36000
# iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
# iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

./kk create cluster --with-kubesphere v3.2.0 # --with-kubernetes v1.21.5
echo '==========================END install kubesphere============================='