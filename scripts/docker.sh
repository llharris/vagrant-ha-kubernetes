#!/usr/bin/env bash

VAGRANT_USER="vagrant"

echo "...Setting network and swap memory..."
modprobe br_netfilter
echo br_netfilter >> /etc/modules
sysctl net.bridge.bridge-nf-call-iptables=1
swapoff -a

echo "...Installing dependencies..."
apt-get update && apt-get install -y ebtables ethtool curl apt-transport-https nfs-common

echo "...Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/docker.list 
deb https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable 
EOF

apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
usermod -a -G docker $VAGRANT_USER