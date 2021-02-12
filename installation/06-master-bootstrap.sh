#!/bin/bash

kubeadm init --control-plane-endpoint "172.20.2.77:6443" --upload-certs --pod-network-cidr=172.20.2.0/24

mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.8/install/kubernetes/quick-install.yaml