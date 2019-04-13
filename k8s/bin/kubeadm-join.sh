#!/bin/env bash

which ansible &> /dev/null
if [[ $? != 0 ]]; then
  # echo "please install ansible according to the following command:"
  # echo "> yum install -y ansible"
  echo "----------------------Install ansible environment----------------------"
  yum install -y ansible
  exit
fi

show_usage="args: [-t|--node_type -c|--ctl-host]"
WD=$(cd $(dirname $(dirname $0)); pwd)
node_type="node"
hosts="k8s-node"
ctl_args=""
ctl_host="192.168.88.120"

while getopts ":t:c:" opt
do
  case $opt in
    t) node_type=$OPTARG;;
    c) ctl_host=$OPTARG;;
    ?) echo "unknow args"; echo $show_usage; exit 1;;
  esac
done

if [[ $node_type == "master" ]]; then
  hosts='k8s-master:!k8s-ctl'
  cert-key=$(ssh $ctl_host 'kubeadm init phase upload-certs --experimental-upload-certs 2>/dev/null|tail -1')
  ctl_args="--experimental-control-plane --certificate-key $cert-key"
fi

join_cmd="$(ssh $ctl_host 'kubeadm token create --print-join-command') --ignore-preflight-errors=Swap $ctl_args"
ansible $hosts -a "$join_cmd"

if [[ $node_type == "master" ]]; then
  ansible $hosts -m file -a 'path=$HOME/.kube state=directory'
  ansible $hosts -m shell -a 'cp -f /etc/kubernetes/admin.conf $HOME/.kube/config'
fi
