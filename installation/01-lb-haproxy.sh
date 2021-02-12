#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as a root" 1>&2
   exit 1
fi

printf "Open firewall\n"

firewall-cmd --add-port 6443/tcp --permanent

# for NFS
firewall-cmd --add-port 80/tcp --permanent
firewall-cmd --add-port 443/tcp --permanent
firewall-cmd --add-port 111/tcp --permanent
firewall-cmd --add-port 111/udp --permanent
firewall-cmd --add-port 2049/tcp --permanent
firewall-cmd --add-port 2049/udp --permanent
firewall-cmd --add-port 1110/tcp --permanent
firewall-cmd --add-port 1110/udp --permanent
firewall-cmd --add-port 4045/tcp --permanent
firewall-cmd --add-port 4045/udp --permanent
firewall-cmd --reload

printf "Haproxy install"

yum -y install haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend kubernetes
    bind 172.20.2.52:6443
    option tcplog
    mode tcp
    timeout connect 10s
    timeout client 1m
    timeout server 1m
    default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
    server master-1 172.20.2.5:6443 check fall 3 rise 2
    server master-2 172.20.2.79:6443 check fall 3 rise 2
    server master-3 172.20.2.167:6443 check fall 3 rise 2    
EOF

setsebool -P haproxy_connect_any=1

printf "Haproxy restart"
service haproxy restart
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy