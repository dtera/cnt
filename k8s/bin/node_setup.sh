#!/usr/bin/env bash

yum install -y yum-utils
yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/docker-ce.repo
yum-config-manager --add-repo=https://raw.githubusercontent.com/dtera/cnt/master/k8s/repo/kubernetes.repo
yum install -y docker-ce kubelet kubeadm
systemctl start docker
systemctl enable docker kubelet

DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
cat <<EOF >/etc/sysconfig/kubelet
KUBELET_CGROUP_ARGS="--cgroup-driver=$DOCKER_CGROUPS"
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF
