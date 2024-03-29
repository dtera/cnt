#!/usr/bin/env bash

# shellcheck disable=SC2046
# shellcheck disable=SC2164
CD=$(cd $(dirname "$0"); pwd)
WD=$(cd $(dirname "$CD"); pwd)
echo "Current Directory: $CD"
echo "Work Directory: $WD"

os_family=$(cat /etc/os-release|grep ID_LIKE)
is_ctl_plane=false
is_standalone=false
install_cmd="yum"
kubelet_conf="/etc/sysconfig/kubelet"

show_usage="args: [-h|--help  -c|--is_ctl_plane  -s|--is_standalone]  \n\
-h|--help         \t\t show help information  \n\
-c|--is_ctl_plane \t   whether current node is control plane \n\
-s|--is_standalone  \t whether the kubenates cluster is standalone"
ARGS=`getopt -o hcs -l help,is_ctl_plane,standalone -n 'kube-setup.sh' -- "$@"`
if [[ $? != 0 ]]; then
  echo "Terminating..."
  exit 1
fi
eval set -- "${ARGS}"

while true
do
  case $1 in
    -h|--help) echo -e ${show_usage}; exit 0;;
    -c|--is_ctl_plane) shift; is_ctl_plane=true;;
    -s|--is_standalone) shift; is_standalone=true;;
    --) shift; break;;
    *) echo "unknown args"; exit 1;;
  esac
done

function add_yum_repo() {
  if [[ ! -e /etc/yum.repos.d/${1##*/} ]]; then
    yum-config-manager --add-repo=$1
  fi
}

if [[ "$os_family" =~ "rhel" ]]; then
  which yum-config-manager &> /dev/null
  if [[ $? != 0 ]]; then
    yum install -y yum-utils
  fi
  add_yum_repo ${WD}/yum/repos/docker-ce.repo
  add_yum_repo ${WD}/yum/repos/kubernetes.repo
cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
  sysctl --system
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
  ${install_cmd} install -y docker-ce
  systemctl start docker
  systemctl enable docker
fi

which kubeadm &> /dev/null
if [[ $? != 0 ]]; then
  ${install_cmd} install -y kubelet kubeadm
  systemctl enable kubelet
fi

DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
cat <<EOF >${kubelet_conf}
KUBELET_CGROUP_ARGS="--cgroup-driver=${DOCKER_CGROUPS}"
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF

if ${is_ctl_plane}; then
  echo 1 > /proc/sys/net/ipv4/ip_forward
  kubeadm init --config=${WD}/kubeadm-config.yml --ignore-preflight-errors=Swap,NumCPU|tee ${WD}/kubeadm-init.log
  mkdir -p $HOME/.kube
  cp -f /etc/kubernetes/admin.conf $HOME/.kube/config

  kubectl apply -f ${WD}/kube-flannel.yml

  if ${is_standalone}; then
    kubectl taint nodes --all node-role.kubernetes.io/master-
  fi
fi
