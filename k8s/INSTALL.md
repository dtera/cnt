The following is about how to install k8s cluster, take centos7 as an example:

-- On the node of k8s cluster, install the related componets about k8s--
* yum install -y yum-utils
* yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/docker-ce.repo
* yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/kubernetes.repo
* yum install -y docker-ce kubelet kubeadm
* systemctl start docker
* systemctl enable docker kubelet

> cat << EOF >/etc/sysconfig/kubelet  
KUBELET_CGROUP_ARGS="--cgroup-driver=cgroupfs"  
KUBELET_EXTRA_ARGS="--fail-swap-on=false"  
EOF

-- On the master node, init the k8s cluster--
* workdir=$(cd $(dirname $(dirname $0)); pwd)
* kubeadm init --config=$workdir/kubeadm-config.yml --experimental-upload-certs --ignore-preflight-errors=Swap
* mkdir -p $HOME/.kube
* cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

-- On the worker node, join the k8s cluster--
* kubeadm join master_ip:6443 --token xxxxxx --discovery-token-ca-cert-hash yyyyyy --ignore-preflight-errors=Swap

-- Deploying flannel manually--  
Flannel can be added to any existing Kubernetes cluster though it's simplest to add flannel before any pods using the pod network have been started. For Kubernetes v1.7+:
* kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/kube-flannel.yml
