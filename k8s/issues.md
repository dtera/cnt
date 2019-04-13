-- error execution phase check-etcd: etcd cluster is not healthy: context deadline exceeded
- wget https://github.com/etcd-io/etcd/releases/download/v3.3.12/etcd-v3.3.12-linux-amd64.tar.gz  
- tar xvf etcd-v3.3.12-linux-amd64.tar.gz  
- cp etcd-v3.3.12-linux-amd64/{etcd,etcdctl} /usr/local/bin/  
- etcdctl --endpoints https://192.168.88.120:2379 --ca-file /etc/kubernetes/pki/etcd/ca.crt \
          --cert-file /etc/kubernetes/pki/etcd/server.crt --key-file /etc/kubernetes/pki/etcd/server.key member list  
- etcdctl --endpoints https://192.168.88.120:2379 --ca-file /etc/kubernetes/pki/etcd/ca.crt \
          --cert-file /etc/kubernetes/pki/etcd/server.crt --key-file /etc/kubernetes/pki/etcd/server.key member remove 7da03a0962bec2b5
  
