#!/bin/env bash

which ansible &> /dev/null
if [[ $? != 0 ]]; then
  # echo "please install ansible according to the following command:"
  # echo "> yum install -y ansible"
  echo "----------------------Install ansible environment----------------------"
  yum install -y ansible
  exit
fi

WD=$(cd $(dirname $(dirname $0)); pwd)
node_type="node"
hosts="k8s-node"
ctl_args=""
ctl_host="192.168.88.120"
local_exec=true

show_usage="args: [-h|--help  -t|--node-type  -c|--ctl-host  -l|local-exec]  \n\
-h|--help       \t\t show help information  \n\
-t|--node-type  \t\t the type of current node(node|master)  \n\
-c|--ctl-host   \t\t the address of control plane host(such as: 192.168.88.120) \n\
-l|--local-exec \t   whether execute in local to join current node into k8s cluster(default true)"
ARGS=`getopt -o ht:c:l:: -l help,node-type:,ctl-host:,local-exec:: -n 'kubeadm-join.sh' -- "$@"`
if [ $? != 0 ]; then
  echo "Terminating..."
  exit 1
fi
eval set -- "$ARGS"

while true
do
  case $1 in
    -h|--help) echo -e $show_usage; exit 0;;
    -t|--node-type) node_type=$2; shift 2;;
    -c|--ctl-host) ctl_host=$2; shift 2;;
    -l|local-exec)
      if [[ $2 != "true" ]]; then
        if [[ $2 != "false" ]]; then
          echo "the arg value of local-exec must be either true or false"
          exit 1
        fi
        local_exec=false
      fi
      shift 2;;
    --) shift; break;;
    *) echo "unknow args"; exit 1;;
  esac
done

# while getopts ":t:c:" opt
# do
#   case $opt in
#     t) node_type=$OPTARG;;
#     c) ctl_host=$OPTARG;;
#     ?) echo "unknow args"; echo $show_usage; exit 1;;
#   esac
# done

if [[ $node_type == "master" ]]; then
  hosts='k8s-master:!k8s-ctl'
  cert_key=$(ssh $ctl_host 'kubeadm init phase upload-certs --experimental-upload-certs 2>/dev/null|tail -1')
  ctl_args="--experimental-control-plane --certificate-key $cert_key"
fi

join_cmd="$(ssh $ctl_host 'kubeadm token create --print-join-command') --ignore-preflight-errors=Swap $ctl_args"
if $local_exec; then
  sh -c "$join_cmd"
else
  ansible $hosts -a "$join_cmd"
fi

if [[ $node_type == "master" ]]; then
  if $local_exec; then
    mkdir -p $HOME/.kube
    cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  else
    ansible $hosts -m file -a 'path=$HOME/.kube state=directory'
    ansible $hosts -m shell -a 'cp -f /etc/kubernetes/admin.conf $HOME/.kube/config'
  fi
fi
