#!/usr/bin/env bash
WD=$(cd $(dirname $(dirname $0)); pwd)

show_usage="args: [-t|--node_type]"
node_type="node"

while getopts ":t:" opt
do
  case $opt in
    t) node_type=$OPTARG;;
    ?) echo "unknow args"; echo $show_usage; exit 1;;
  esac
done

which yum-config-manager &> /dev/null
if [[ $? != 0 ]]; then
  yum install -y yum-utils
fi

if [ ! -e /etc/yum.repos.d/docker-ce.repo ]; then
  yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/docker-ce.repo
fi
if [ ! -e /etc/yum.repos.d/kubernetes.repo ]; then
  yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/kubernetes.repo
fi

which docker &> /dev/null
if [[ $? != 0 ]]; then
  yum install -y docker-ce
  systemctl start docker
  systemctl enable docker
fi

which kubeadm &> /dev/null
if [[ $? != 0 ]]; then
  yum install -y kubelet kubeadm
  systemctl enable kubelet
fi
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
cat <<EOF >/etc/sysconfig/kubelet
KUBELET_CGROUP_ARGS="--cgroup-driver=$DOCKER_CGROUPS"
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF

if [[ $node_type == "master" ]]; then
  kubeadm init --config=$WD/kubeadm-config.yml --experimental-upload-certs --ignore-preflight-errors=Swap|tee $WD/kubeadm-init.log
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

  kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/kube-flannel.yml
fi
