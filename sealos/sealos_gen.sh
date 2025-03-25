#!/bin/bash

# 生成包含 Kubernetes、Helm、Calico 的配置文件
sealos gen registry.cn-shanghai.aliyuncs.com/labring/kubernetes:v1.31.0 \
    registry.cn-shanghai.aliyuncs.com/labring/helm:v3.9.4 \
    registry.cn-shanghai.aliyuncs.com/labring/calico:v3.24.1 \
    --masters 127.0.0.1 \
    --nodes 127.0.0.1 \
    --passwd 123456 \
    --port 22 \
    --output Clusterfile
