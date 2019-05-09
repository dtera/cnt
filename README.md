## [Cloud Native Technology](https://github.com/dtera/cnt)  
![Author](https://img.shields.io/badge/author-zhaohq-red.svg) ![Language](https://img.shields.io/badge/language-Go%20%2F%20YAML%20etc-orange.svg) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.md) [![SayThanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)](https://saythanks.io/to/dtera)

-- install kubernetes cluster
> please refer to ./k8s/INSTALL.md

-- deploy ingress-nginx
> kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/ingress-nginx/mandatory.yml

-- install helm and tiller
- Download your [desired version](https://github.com/helm/helm/releases)
- Unpack it (tar -zxvf helm-v2.0.0-linux-amd64.tgz)
- Find the helm binary in the unpacked directory, and move it to its desired destination (mv linux-amd64/helm /usr/local/bin/helm)
- kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/helm/rbac-config.yml
- helm init -i registry.aliyuncs.com/google_containers/tiller:v2.13.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts --service-account tiller
