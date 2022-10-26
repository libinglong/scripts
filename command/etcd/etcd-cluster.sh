#!/usr/bin/env bash

CERT_DIR=/root/git-repo/scripts/build/etcd

docker rm -f s1
docker rm -f s2
docker rm -f s3

docker run -d \
  --restart=always \
  --net=host \
  --name s1 \
  --volume=/tmp/etcd/s1:/etcd-data \
  --volume=${CERT_DIR}:/etcd-ssl-certs-dir \
  gcr.io/etcd-development/etcd:v3.3.8 \
  /usr/local/bin/etcd \
  --name s1 \
  --data-dir /etcd-data \
  --listen-client-urls https://localhost:2379 \
  --advertise-client-urls https://localhost:2379 \
  --listen-peer-urls https://localhost:2380 \
  --initial-advertise-peer-urls https://localhost:2380 \
  --initial-cluster s1=https://localhost:2380,s2=https://localhost:22380,s3=https://localhost:32380 \
  --initial-cluster-token tkn \
  --initial-cluster-state new \
  --client-cert-auth \
  --trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --cert-file /etcd-ssl-certs-dir/s1.pem \
  --key-file /etcd-ssl-certs-dir/s1-key.pem \
  --peer-client-cert-auth \
  --peer-trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --peer-cert-file /etcd-ssl-certs-dir/s1.pem \
  --peer-key-file /etcd-ssl-certs-dir/s1-key.pem



docker run -d \
  --restart=always \
  --net=host \
  --name s2 \
  --volume=/tmp/etcd/s2:/etcd-data \
  --volume=${CERT_DIR}:/etcd-ssl-certs-dir \
  gcr.io/etcd-development/etcd:v3.3.8 \
  /usr/local/bin/etcd \
  --name s2 \
  --data-dir /etcd-data \
  --listen-client-urls https://localhost:22379 \
  --advertise-client-urls https://localhost:22379 \
  --listen-peer-urls https://localhost:22380 \
  --initial-advertise-peer-urls https://localhost:22380 \
  --initial-cluster s1=https://localhost:2380,s2=https://localhost:22380,s3=https://localhost:32380 \
  --initial-cluster-token tkn \
  --initial-cluster-state new \
  --client-cert-auth \
  --trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --cert-file /etcd-ssl-certs-dir/s2.pem \
  --key-file /etcd-ssl-certs-dir/s2-key.pem \
  --peer-client-cert-auth \
  --peer-trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --peer-cert-file /etcd-ssl-certs-dir/s2.pem \
  --peer-key-file /etcd-ssl-certs-dir/s2-key.pem


docker run -d \
  --restart=always \
  --net=host \
  --name s3 \
  --volume=/tmp/etcd/s3:/etcd-data \
  --volume=${CERT_DIR}:/etcd-ssl-certs-dir \
  gcr.io/etcd-development/etcd:v3.3.8 \
  /usr/local/bin/etcd \
  --name s3 \
  --data-dir /etcd-data \
  --listen-client-urls https://localhost:32379 \
  --advertise-client-urls https://localhost:32379 \
  --listen-peer-urls https://localhost:32380 \
  --initial-advertise-peer-urls https://localhost:32380 \
  --initial-cluster s1=https://localhost:2380,s2=https://localhost:22380,s3=https://localhost:32380 \
  --initial-cluster-token tkn \
  --initial-cluster-state new \
  --client-cert-auth \
  --trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --cert-file /etcd-ssl-certs-dir/s3.pem \
  --key-file /etcd-ssl-certs-dir/s3-key.pem \
  --peer-client-cert-auth \
  --peer-trusted-ca-file /etcd-ssl-certs-dir/etcd-root-ca.pem \
  --peer-cert-file /etcd-ssl-certs-dir/s3.pem \
  --peer-key-file /etcd-ssl-certs-dir/s3-key.pem