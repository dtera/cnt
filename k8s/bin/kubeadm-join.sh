#!/usr/bin/env bash

WD=$(cd $(dirname $(dirname $0)); pwd)
os_family=$(cat /etc/os-release|grep ID_LIKE)
node_type="node"
hosts="k8s-node"
ctl_args=""
ctl_host="192.168.88.120"
remote_exec=false
install_cmd="yum"

show_usage="args: [-h|--help  -t|--node-type  -c|--ctl-host  -r|remote-exec]  \n\
-h|--help       \t\t show help information  \n\
-t|--node-type  \t\t the type of current node(node|master)  \n\
-c|--ctl-host   \t\t the address of control plane host(such as: 192.168.88.120) \n\
-r|--remote-exec \t  whether executes in remote hosts to join corresponding nodes into k8s cluster(default false)"
ARGS=`getopt -o ht:c:r:: -l help,node-type:,ctl-host:,remote-exec:: -n 'kubeadm-join.sh' -- "$@"`
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
    -r|--remote-exec)
      if [[ $2 != "false" ]]; then
        if [[ $2 != "" && $2 != "true" ]]; then
          echo "the arg value of remote-exec must be either true or false"
          exit 1
        fi
        remote_exec=true
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

if [[ "$os_family" =~ "debian" ]]; then
  install_cmd="apt-get"
fi

which ansible &> /dev/null
if [[ $? != 0 ]]; then
  # echo "please install ansible according to the following command:"
  # echo "> $install_cmd install -y ansible"
  echo "----------------------Install ansible environment----------------------"
  $install_cmd install -y ansible
  exit
fi

if [[ $node_type == "master" ]]; then
  hosts='k8s-master:!k8s-ctl'
  cert_key=$(ssh $ctl_host 'kubeadm init phase upload-certs --experimental-upload-certs 2>/dev/null|tail -1')
  ctl_args="--experimental-control-plane --certificate-key $cert_key"
fi

join_cmd="$(ssh $ctl_host 'kubeadm token create --print-join-command') --ignore-preflight-errors=Swap $ctl_args"
if $remote_exec; then
  ansible $hosts -i $WD/inventory -a "$join_cmd"
else
  $join_cmd
fi

if [[ $node_type == "master" ]]; then
  if $remote_exec; then
    ansible $hosts -i $WD/inventory -m file -a 'path=$HOME/.kube state=directory'
    ansible $hosts -i $WD/inventory -m shell -a 'cp -f /etc/kubernetes/admin.conf $HOME/.kube/config'
  else
    mkdir -p $HOME/.kube
    cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
  fi
fi
