## [Cloud Native Technology](https://github.com/dtera/cnt)  
![Author](https://img.shields.io/badge/author-zhaohq-red.svg) ![Language](https://img.shields.io/badge/language-Go%20%2F%20YAML%20etc-orange.svg) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.md) [![SayThanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)](https://saythanks.io/to/dtera)

-- install docker composer
```bash
compose_version='1.24.0'
curl -L https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

-- install kubernetes cluster
> please refer to ./k8s/INSTALL.md

-- deploy ingress-nginx
```bash
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/ingress-nginx/mandatory.yml
```

-- deploy ingress-traefik
```bash
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/ingress-traefik/traefik-rbac.yml  
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/ingress-traefik/traefik-ds.yml
```

-- deploy kubernetes dashboard
```bash
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/dashboard/dashboard-admin-rbac.yml  
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/dashboard/dashboard.yml  
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

-- install helm and tiller
- Download your [desired version](https://github.com/helm/helm/releases)
- Unpack it (tar -xvf helm-v2.0.0-linux-amd64.tgz)
- Find the helm binary in the unpacked directory, and move it to its desired destination (mv linux-amd64/helm /usr/local/bin/helm)
```bash
helm_version='v2.14.0'
curl -L https://storage.googleapis.com/kubernetes-helm/helm-${helm_version}-linux-amd64.tar.gz
tar -xvf helm-${helm_version}-linux-amd64.tgz
mv linux-amd64/helm /usr/local/bin/helm
rm linux-amd64 -rf
chmod +x /usr/local/bin/helm
kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/manifests/helm/rbac-config.yml
helm init -i registry.aliyuncs.com/google_containers/tiller:v2.13.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts --service-account tiller
```

-- install harbor
- download package and unarchive it  
```bash
harbor_version='1.7.5'
curl -L https://storage.googleapis.com/harbor-releases/release-${harbor_version}/harbor-online-installer-v${harbor_version}.tgz
tar -xvf harbor-online-installer-v${harbor_version}.tgz -C /usr/local/cnt/
```
- cd /usr/local/harbor
- vim harbor.cfg  
```
hostname=harbor.cnt.io
email_server=smtp.qq.com
email_server_port=25
email_username=346091714@qq.com
email_password=123456
email_from=zhaohq <346091714@qq.com>
email_ssl=false
harbor_admin_password = harbor@5133
self_registration=off
project_creation_restriction=adminonly
```
- issue the following commands
```bash
./prepare
./install.sh
```

