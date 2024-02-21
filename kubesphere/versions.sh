#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit

# shellcheck disable=SC2034
kk_ver=3.0.10
# shellcheck disable=SC2034
ks_ver=3.4.0
# shellcheck disable=SC2034
k8s_ver=1.23.10
# shellcheck disable=SC2034
password=123
