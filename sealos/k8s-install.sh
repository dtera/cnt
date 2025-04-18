#!/usr/bin/env bash

# shellcheck disable=SC2154
# shellcheck disable=SC2181
# shellcheck disable=SC2269
# shellcheck disable=SC2086

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
echo "Current Directory: $CD"

source "$CD"/config.sh gen_dir
passwd=$passwd

show_usage="args: [-h|--help  -s|--single -i|--ingress_nginx -c|--cilium -p|--passwd ]  \n\
-h|--help         \t\t show help information  \n\
-s|--single       \t\t all in one node \n\
-i|--ingress_nginx  \t whether install ingress_nginx \n\
-c|--cilium       \t\t whether install cilium \n\
-p|--passwd       \t\t passwd of host"
ARGS=$(getopt -o hsicp: -l help,single,ingress_nginx,cilium,passwd: -n 'k8s-install.sh' -- "$@")
if [[ $? != 0 ]]; then
  echo "Terminating..."
  exit 1
fi
eval set -- "${ARGS}"

opt="--masters $masters --nodes $nodes"
while true
do
  case $1 in
    -h|--help) echo -e "${show_usage}"; exit 0;;
    -s|--single) shift; opt="$opt --single";;
    -i|--ingress_nginx) shift; opt="registry.cn-shanghai.aliyuncs.com/labring/ingress-nginx:v$ingress_nginx_v $opt";;
    -c|--cilium) shift; opt="registry.cn-shanghai.aliyuncs.com/labring/cilium:v$cilium_v $opt";;
    -p|--passwd)  passwd=$2; shift 2;;
    --) shift; break;;
    *) echo "unknown args"; exit 1;;
  esac
done


which sshpass &> /dev/null
if [[ $? != 0 ]]; then
  yum install -y sshpass
fi
for node in $(echo "$nodes" | tr "," "\n")
do
    sshpass -p "$passwd" ssh -p "$port" "root@$node" 'bash -s' < "$CD"/config.sh gen_dir
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

kubectl taint node admin node-role.kubernetes.io/control-plane:NoSchedule-
kubectl label nodes admin node-role.kubernetes.io/master= node-role.kubernetes.io/worker=
