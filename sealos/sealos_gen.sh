#!/bin/bash

# 生成包含 Kubernetes、Helm、Calico 的配置文件
sealos gen labring/kubernetes:v1.25.0 labring/helm:v3.8.2 labring/calico:v3.24.1 \
    --masters 127.0.0.1 \
    --nodes 127.0.0.1 \
    --passwd 123456 \
    --port 22 \
    -o Clusterfile
