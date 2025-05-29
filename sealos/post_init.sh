#!/usr/bin/env bash


cat << EOF >/etc/docker/daemon.json
{
  "max-concurrent-downloads": 20,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "insecure-registries": [
    "sealos.hub:5000"
  ],
  "data-root": "/var/lib/docker",
  "registry-mirrors": ["https://h5yupgq1.mirror.aliyuncs.com"]
}
EOF

systemctl daemon-reload
systemctl restart docker

