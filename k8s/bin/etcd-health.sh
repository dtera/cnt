#!/usr/bin/env bash

endpoints='https://192.168.88.120:2379'
if [[ $1 != "" ]]; then
  endpoints=$1
fi

docker run --rm -it --net host \
-v /etc/kubernetes:/etc/kubernetes \
registry.aliyuncs.com/google_containers/etcd:3.3.10 \
etcdctl \
--cert-file /etc/kubernetes/pki/etcd/peer.crt \
--key-file /etc/kubernetes/pki/etcd/peer.key \
--ca-file /etc/kubernetes/pki/etcd/ca.crt \
--endpoints ${endpoints} \
cluster-health