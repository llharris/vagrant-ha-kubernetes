#!/bin/bash
if [ -f /etc/kubernetes/pki/etcd/config.json ]; then
  export PEER_NAME=$(hostname)
  export PRIVATE_IP=$(ip addr show eth1 | grep -Po 'inet \K[\d.]+')
  sed -i '0,/CN/{s/example\.net/'"$PEER_NAME"'/}' /etc/kubernetes/pki/etcd/config.json
  sed -i 's/www\.example\.net/'"$PRIVATE_IP"'/' /etc/kubernetes/pki/etcd/config.json
  sed -i 's/example\.net/'"$PEER_NAME"'/' /etc/kubernetes/pki/etcd/config.json
else
  exit 1
fi
exit 0
