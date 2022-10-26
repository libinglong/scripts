#!/usr/bin/env bash


ETCD_ENDPOINTS=https://localhost:22379,https://localhost:2379,https://localhost:32379
ADVERTISE_IP=192.160.3.30
CERT_DIR=/root/git-repo/scripts/build

docker rm -f apiserver

docker run \
  --name apiserver \
  -d \
  --restart=always \
  --net=host \
  -v ${CERT_DIR}:/certs \
  registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.23.3 \
    kube-apiserver \
    --advertise-address=${ADVERTISE_IP} \
    --allow-privileged=true \
    --authorization-mode=Node,RBAC \
    --client-ca-file=/certs/k8s-ca/myk8s-root.pem \
    --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
    --enable-bootstrap-token-auth=true \
    --etcd-cafile=/certs/etcd/etcd-root-ca.pem \
    --etcd-certfile=/certs/etcd/s1.pem \
    --etcd-keyfile=/certs/etcd/s1-key.pem \
    --etcd-servers=${ETCD_ENDPOINTS} \
    --kubelet-client-certificate=/certs/apiserver/kube-apiserver-kubelet-client.pem \
    --kubelet-client-key=/certs/apiserver/kube-apiserver-kubelet-client-key.pem \
    --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \
    --proxy-client-cert-file=/certs/apiserver/front-proxy-client.pem \
    --proxy-client-key-file=/certs/apiserver/front-proxy-client-key.pem \
    --requestheader-allowed-names=front-proxy-client \
    --requestheader-client-ca-file=/certs/k8s-ca/front-proxy-ca.pem \
    --requestheader-extra-headers-prefix=X-Remote-Extra- \
    --requestheader-group-headers=X-Remote-Group \
    --requestheader-username-headers=X-Remote-User \
    --secure-port=8443 \
    --service-account-issuer=https://kubernetes.default.svc.cluster.local \
    --service-account-key-file=/certs/apiserver/sa.pub \
    --service-account-signing-key-file=/certs/apiserver/sa.key \
    --service-cluster-ip-range=10.96.0.0/12 \
    --tls-cert-file=/certs/apiserver/apiserver-tls.pem \
    --tls-private-key-file=/certs/apiserver/apiserver-tls-key.pem
