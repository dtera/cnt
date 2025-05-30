#!/usr/bin/env bash

# shellcheck disable=SC2154
# shellcheck disable=SC2181
# shellcheck disable=SC2269
# shellcheck disable=SC2086

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
echo "Current Directory: $CD"

source "$CD"/config.sh
passwd=$passwd
masters=$masters
nodes=$nodes

show_usage="args: [-h|--help  -s|--single -i|--ingress_nginx -c|--cilium -p|--passwd -m|--masters -n|--nodes ]  \n\
-h|--help         \t\t show help information  \n\
-s|--single       \t\t all in one node \n\
-i|--ingress_nginx  \t whether install ingress_nginx \n\
-c|--cilium       \t\t whether install cilium \n\
-p|--passwd       \t\t passwd of host \n\
-m|--masters      \t\t masters of k8s cluster \n\
-n|--nodes        \t\t nodes of k8s cluster"
ARGS=$(getopt -o hsicp:m:n: -l help,single,ingress_nginx,cilium,passwd:,masters:,nodes: -n 'k8s-install.sh' -- "$@")
if [[ $? != 0 ]]; then
  echo "Terminating..."
  exit 1
fi
eval set -- "${ARGS}"

opt=""
while true
do
  case $1 in
    -h|--help) echo -e "${show_usage}"; exit 0;;
    -s|--single) shift; opt="$opt --single";;
    -i|--ingress_nginx) shift; opt="registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v$ingress_nginx_v $opt";;
    -c|--cilium) shift; opt="registry.cn-shanghai.aliyuncs.com/labring/cilium:v$cilium_v $opt";;
    -p|--passwd)  passwd=$2; shift 2;;
    -m|--masters) masters=$2; shift 2;;
    -n|--nodes)   nodes=$2; shift 2;;
    --) shift; break;;
    *) echo "unknown args"; exit 1;;
  esac
done
if [[ ! "$opt" =~ "--single" ]]; then
  opt="$opt --masters $masters --nodes $nodes"
fi


which sshpass &> /dev/null
if [[ $? != 0 ]]; then
  yum install -y sshpass
fi
for node in $(echo "$nodes,$masters" | tr "," "\n")
do
    echo "config for node $node"
    sshpass -p "$passwd" ssh -p "$port" "root@$node" -o StrictHostKeyChecking=no 'bash -s' < "$CD"/pre_init.sh 2>/dev/null
done

which sealos &> /dev/null
if [[ $? != 0 ]]; then
  curl -sfL "${PROXY_PREFIX}"/https://raw.githubusercontent.com/labring/sealos/main/scripts/install.sh | \
  PROXY_PREFIX=${PROXY_PREFIX} sh -s "${SEALOS_VERSION}" labring/sealos
fi

sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v"$k8s_v" \
           registry.cn-shanghai.aliyuncs.com/labring/helm:v"$helm_v" \
           registry.cn-shanghai.aliyuncs.com/labring/openebs:v"$openebs_v" \
           registry.cn-shanghai.aliyuncs.com/labring/minio-operator:v"$minio_v" \
           $opt --port $port --passwd $passwd

# post init after installing k8s
for node in $(echo "$nodes,$masters" | tr "," "\n")
do
    echo "post init for node $node"
    sshpass -p "$passwd" ssh -p "$port" "root@$node" -o StrictHostKeyChecking=no 'bash -s' < "$CD"/post_init.sh 2>/dev/null
done

kubectl taint node admin node-role.kubernetes.io/control-plane:NoSchedule-
kubectl label nodes admin node-role.kubernetes.io/master= node-role.kubernetes.io/worker=
