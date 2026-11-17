#!/bin/bash
apt-get update -y
apt-get install -y curl awscli

MASTER_IP="${master_ip}"

until curl -kfsS "https://${MASTER_IP}:6443/ping"; do
  sleep 10
done
        
TOKEN=$(aws ssm get-parameter \
    --name "/k3s/cluster/node-token" \
    --with-decryption \
    --region eu-north-1 \
    --query "Parameter.Value" \
    --output text)
    
curl -sfL https://get.k3s.io | \
    INSTALL_K3S_VERSION="v1.31.8+k3s1" \
    K3S_URL=https://${MASTER_IP}:6443 \
    K3S_TOKEN="$TOKEN" sh -