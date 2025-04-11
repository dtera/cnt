#!/usr/bin/env bash

# shellcheck disable=SC2034

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit


k8s_v="1.28.0"
helm_v="3.15.4"
cilium_v="1.13.18"
openebs_v="3.10.0"
minio_v="5.0.6"
ingress_nginx_v="1.12.1"

masters="9.135.90.159"
nodes="9.135.117.186"
port="36000" # 22
passwd="123456"
