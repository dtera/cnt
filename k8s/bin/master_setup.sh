#!/usr/bin/env bash

sh node_setup.sh

workdir=$(cd $(dirname $(dirname $0)); pwd)
kubeadm init --config=$workdir/kubeadm-config.yml --experimental-upload-certs --ignore-preflight-errors=Swap > $workdir/kubeadm-init.log
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/kube-flannel.yml
