#!/usr/bin/env bash

sh node_setup.sh

kubeadm init --ignore-preflight-errors=Swap --image-repository=registry.aliyuncs.com/google_containers --pod-network-cidr 10.244.0.0/16
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/dtera/cnt/master/k8s/kube-flannel.yml
