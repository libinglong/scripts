#!/usr/bin/env bash

CERT_DIR=/root/git-repo/scripts/build

docker rm -f kube-scheduler

docker run \
  -d \
  --net=host \
  --restart=always \
  --name kube-scheduler \
  -v ${CERT_DIR}:/certs \
  registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.23.3 \
    kube-scheduler \
    --authentication-kubeconfig=/certs/kubeconfig/kube-scheduler.conf \
    --authorization-kubeconfig=/certs/kubeconfig/kube-scheduler.conf \
    --bind-address=127.0.0.1 \
    --kubeconfig=/certs/kubeconfig/kube-scheduler.conf \
    --leader-elect=false