#!/usr/bin/env bash

set -x

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit


# install ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace