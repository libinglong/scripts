#!/usr/bin/env bash

CERT_DIR=/root/git-repo/scripts/build

docker rm -f kube-controller-manager

docker run \
  -d \
  --net=host \
  --name kube-controller-manager \
  --restart=always \
  -v ${CERT_DIR}:/certs \
  registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.23.3 \
  kube-controller-manager \
    --allocate-node-cidrs=true \
    --authentication-kubeconfig=/certs/kubeconfig/kube-controller-manager.conf \
    --authorization-kubeconfig=/certs/kubeconfig/kube-controller-manager.conf \
    --bind-address=127.0.0.1 \
    --client-ca-file=/certs/k8s-ca/myk8s-root.pem \
    --cluster-cidr=10.244.0.0/16 \
    --cluster-name=mk \
    --cluster-signing-cert-file=/certs/k8s-ca/myk8s-root.pem \
    --cluster-signing-key-file=/certs/k8s-ca/myk8s-root-key.pem \
    --controllers=*,bootstrapsigner,tokencleaner \
    --kubeconfig=/certs/kubeconfig/kube-controller-manager.conf \
    --leader-elect=false \
    --requestheader-client-ca-file=/certs/k8s-ca/front-proxy-ca.pem \
    --root-ca-file=/certs/k8s-ca/myk8s-root.pem \
    --service-account-private-key-file=/certs/apiserver/sa.key \
    --service-cluster-ip-range=10.96.0.0/12 \
    --use-service-account-credentials=true

