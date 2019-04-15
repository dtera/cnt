#!/usr/bin/env bash

WD=$(cd $(dirname $(dirname $0)); pwd)
os_family=$(cat /etc/os-release|grep ID_LIKE)
is_ctl_plane=false
install_cmd="yum"
kubelet_conf="/etc/sysconfig/kubelet"

show_usage="args: [-h|--help  -c|--is_ctl_plane]  \n\
-h|--help          \t show help information  \n\
-c|--is_ctl_plane  \t whether current node is control plane"
ARGS=`getopt -o hc -l help,is_ctl_plane -n 'kube-setup.sh' -- "$@"`
if [ $? != 0 ]; then
  echo "Terminating..."
  exit 1
fi
eval set -- "$ARGS"

while true
do
  case $1 in
    -h|--help) echo -e $show_usage; exit 0;;
    -c|--is_ctl_plane) shift; is_ctl_plane=true;;
    --) shift; break;;
    *) echo "unknow args"; exit 1;; 
  esac
done

if [[ "$os_family" =~ "rhel" ]]; then
  which yum-config-manager &> /dev/null
  if [[ $? != 0 ]]; then
    yum install -y yum-utils
  fi
  if [ ! -e /etc/yum.repos.d/docker-ce.repo ]; then
    yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/yum/repos/docker-ce.repo
  fi
  if [ ! -e /etc/yum.repos.d/kubernetes.repo ]; then
    yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/yum/repos/kubernetes.repo
  fi
fi

if [[ "$os_family" =~ "debian" ]]; then
  install_cmd="apt-get"
  kubelet_conf="/etc/default/kubelet"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg|apt-key add -
  curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg|apt-key add -
  # add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
#deb https://apt.kubernetes.io/ kubernetes-xenial main
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
  apt-get update
fi

which docker &> /dev/null
if [[ $? != 0 ]]; then
  sh -c "$install_cmd install -y docker-ce"
  systemctl start docker
  systemctl enable docker
fi

which kubeadm &> /dev/null
if [[ $? != 0 ]]; then
  sh -c "$install_cmd install -y kubelet kubeadm"
  systemctl enable kubelet
fi

DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
cat <<EOF >$kubelet_conf
KUBELET_CGROUP_ARGS="--cgroup-driver=$DOCKER_CGROUPS"
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF

if $is_ctl_plane; then
  kubeadm init --config=$WD/kubeadm-config.yml --experimental-upload-certs --ignore-preflight-errors=Swap|tee $WD/kubeadm-init.log
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

  kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/kube-flannel.yml
fi
