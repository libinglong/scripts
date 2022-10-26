#!/usr/bin/env bash

NODE_IP=$1
PROJECT_DIR=/root/git-repo/scripts

kubelet \
  --bootstrap-kubeconfig=build/kubeconfig/bootstrap-kubelet.conf \
  --config=${PROJECT_DIR}/k8s-node/config.yaml \
  --housekeeping-interval=5m \
  --kubeconfig=${PROJECT_DIR}/build/kubeconfig/${NODE_IP}-kubelet.conf \
  --node-ip=${NODE_IP} \
  --hostname-override=${NODE_IP} \
  --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6 \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock \
  --container-runtime=remote

# 如果container-runtime=docker，那么需要添加--network-plugin=cni，才能使用cni网络
# 如果container-runtime=docker，可能需要添加--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice，
# 否则kubelet会报"Failed to get system container stats"，但我不清楚会影响什么。