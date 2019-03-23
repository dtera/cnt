The following is about how to install k8s cluster, take centos7 as an example:

-- In the node of k8s cluster, install the related componets about k8s--
* yum install -y yum-utils
* yum-config-manager --add-repo=https://github.com/dtera/cnt/blob/master/k8s/repo/docker-ce.repo
* yum-config-manager --add-repo=https://github.com/dtera/cnt/blob/master/k8s/repo/kubernetes.repo
* yum install -y docker-ce kubelet kubeadm kubectl
* systemctl start docker
* systemctl enable docker kubelet

> cat << EOF >/etc/sysconfig/kubelet  
KUBELET_EXTRA_ARGS="--fail-swap-on=false"  
EOF

-- In the master node, init the k8s cluster--
* kubeadm init --ignore-preflight-errors=Swap --image-repository=registry.aliyuncs.com/google_containers
* mkdir -p $HOME/.kube
* cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

-- In the worker node, join the k8s cluster--
* kubeadm join master_ip:6443 --token xxxxxx --discovery-token-ca-cert-hash yyyyyy --ignore-preflight-errors=Swap
