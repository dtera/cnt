#!/usr/bin/env bash
CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

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

[ "$1" == "config" ] && (which kk || sh "$CD"/kk-config.sh) && arg=${arg:6} && (shift 1)
[ "$1" == "allinone" ] && arg=""

sh "$CD"/patches.sh

# shellcheck disable=SC2154
kk create cluster $arg #--with-kubesphere v"$ks_ver" --with-kubernetes v"$k8s_ver"
echo '==========================END install kubesphere============================='
