The following is about how to install k8s cluster, take centos7 as an example:

-- On the node of k8s cluster, install the related components about k8s--
```bash
yum install -y yum-utils
# https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo=https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/yum/repos/docker-ce.repo
yum-config-manager --add-repo=https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/yum/repos/kubernetes.repo
yum install -y docker-ce kubelet kubeadm
systemctl start docker
systemctl enable docker kubelet

cat << EOF >/etc/sysconfig/kubelet  
KUBELET_CGROUP_ARGS="--cgroup-driver=cgroupfs"  
KUBELET_EXTRA_ARGS="--fail-swap-on=false"  
EOF
```

-- On the master node, init the k8s cluster--
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
workdir=$(cd $(dirname $(dirname $0)); pwd)
kubeadm init --config=${workdir}/kubeadm-config.yml --ignore-preflight-errors=Swap,NumCPU
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

-- On the worker node, join the k8s cluster--
```bash
kubeadm join master_ip:6443 --token xxxxxx --discovery-token-ca-cert-hash yyyyyy --ignore-preflight-errors=Swap
```

-- Deploying flannel manually--  
Flannel can be added to any existing Kubernetes cluster though it's simplest to add flannel before any pods using the pod network have been started. For Kubernetes v1.7+:
```bash
kubectl apply -f https://raw.githubusercontent.com/zhaohuiqiang/cnt/master/k8s/kube-flannel.yml
```
