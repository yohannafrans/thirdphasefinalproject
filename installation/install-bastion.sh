#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

printf "Open firewall\n"

firewall-cmd --add-port 6443/tcp --permanent
firewall-cmd --reload

printf "Haproxy install for bastion host"

yum -y install haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg 
frontend http
    bind *:80
    option tcplog
    mode tcp
    timeout connect 10s
    timeout client 1m
    timeout server 1m
    default_backend http-lb

backend http-lb
    mode tcp
    balance roundrobin
    option tcp-check
    server loadbalancer 172.20.2.46:80 check fall 3 rise 2
EOF

setsebool -P haproxy_connect_any=1

printf "Restart"
service haproxy restart
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy