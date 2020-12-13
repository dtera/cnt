### [Cloud Native Technology](https://github.com/dtera/cnt)  
![Author](https://img.shields.io/badge/author-zhaohq-red.svg) ![Language](https://img.shields.io/badge/language-Go%20%2F%20YAML%20etc-orange.svg) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.md) [![SayThanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)](https://saythanks.io/to/dtera)

#### install tensorflow-gpu
```bash
pip install tensorflow-gpu -i https://pypi.tuna.tsinghua.edu.cn/simple  # https://mirrors.aliyun.com/pypi/simple

```

#### install docker composer
```bash
compose_version='1.24.0'
curl -L https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

#### install kubernetes cluster
- please refer to ./k8s/INSTALL.md

#### deploy ingress-nginx
```bash
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/manifests/ingress-nginx/mandatory.yml
```

#### deploy ingress-traefik
```bash
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/manifests/ingress-traefik/mandatory.yml  
```

#### deploy kubernetes dashboard
```bash
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/manifests/dashboard/dashboard-admin-rbac.yml  
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/manifests/dashboard/dashboard.yml  
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

# recommended
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
```

#### install helm and tiller
- Download your [desired version](https://github.com/helm/helm/releases)
- Unpack it (tar -xvf helm-v2.0.0-linux-amd64.tgz)
- Find the helm binary in the unpacked directory, and move it to its desired destination (mv linux-amd64/helm /usr/local/bin/helm)
```bash
helm_version='v3.4.2'
curl -L https://storage.googleapis.com/kubernetes-helm/helm-${helm_version}-linux-amd64.tar.gz
tar -xvf helm-${helm_version}-linux-amd64.tgz
mv linux-amd64/helm /usr/local/bin/helm
rm linux-amd64 -rf
chmod +x /usr/local/bin/helm
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/manifests/helm/rbac-config.yml
helm init -i registry.aliyuncs.com/google_containers/tiller:v2.13.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts --service-account tiller
```

#### install harbor
- download package and unarchive it  
```bash
harbor_version='1.10.4'
wget https://github.com/goharbor/harbor/releases/download/v${harbor_version}/harbor-offline-installer-v${harbor_version}.tgz
# curl -L https://storage.googleapis.com/harbor-releases/release-${harbor_version}/harbor-online-installer-v${harbor_version}.tgz
tar -xvf harbor-online-installer-v${harbor_version}.tgz -C /usr/local/cnt/
```
- cd /usr/local/harbor
- vim harbor.cfg  
```
hostname=harbor.cnt.io
ui_url_protocol = https
ssl_cert = /data/cert/registry.cnt.io.crt
ssl_cert_key = /data/cert/registry.cnt.io.key
  
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
- ./install.sh
- issue the following commands to configure harbor with https access
```bash
mkdir pki
cd pki

# ===============================Getting Certificate Authority========================================
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
-subj "/C=CN/ST=Wuhan/L=Wuhan/O=registry/OU=Personal/CN=registry.cnt.io" \
-key ca.key \
-out ca.crt

# ===============================Getting Server Certificate===========================================
# 1. Create your own Private Key:
openssl genrsa -out registry.cnt.io.key 4096
# 2. Generate a Certificate Signing Request:
openssl req -new -sha512 \
-subj "/C=CN/ST=Wuhan/L=Wuhan/O=registry/OU=Personal/CN=registry.cnt.io" \
-key registry.cnt.io.key \
-out registry.cnt.io.csr
# 3. Generate the certificate of your registry host:
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names

[alt_names]
DNS.1=registry.cnt.io
DNS.2=registry
EOF

openssl x509 -req -sha512 -days 3650 \
-extfile v3.ext \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-in registry.cnt.io.csr \
-out registry.cnt.io.crt

# ===============================Configuration and Installation=======================================
# 1. Configure Server Certificate and Key for Harbor
cp registry.cnt.io.crt /data/cert/
cp registry.cnt.io.key /data/cert/
# 2. Configure Server Certificate, Key and CA for Docker
openssl x509 -inform PEM -in registry.cnt.io.crt -out registry.cnt.io.cert
mkdir -p /etc/docker/certs.d/registry.cnt.io
cp ca.crt registry.cnt.io.key registry.cnt.io.cert /etc/docker/certs.d/registry.cnt.io/
cd ../
# Generate configuration files for Harbor:
./prepare
# If Harbor is already running, stop and remove the existing instance. Your image data remain in the file system
docker-compose down -v
# Finally, restart Harbor:
docker-compose up -d
# Open a browser and enter the address: https://registry.cnt.io. It should display the user interface of Harbor
```

