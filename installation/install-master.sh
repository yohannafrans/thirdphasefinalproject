#!/bin/bash
# 02-enable-br-netfilter.sh
cat <<EOF | sudo tee /etc/sysctl.d/00-system.conf
net.ipv4.ip_forward = 1
EOF

modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

# 03-master-firewall.sh
firewall-cmd --add-port 6443/tcp --permanent
firewall-cmd --add-port 2379-2380/tcp --permanent
firewall-cmd --add-port 10250/tcp --permanent
firewall-cmd --add-port 10251/tcp --permanent
firewall-cmd --add-port 10252/tcp --permanent
firewall-cmd --reload

# 05-kubeadm-install.sh
swapoff -a

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet-1.19.1 kubeadm-1.19.1 kubectl-1.19.1 --disableexcludes=kubernetes

sudo systemctl enable --now kubelet