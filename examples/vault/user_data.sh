#!/bin/bash

yum install -y yum-utils

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

yum install -y vault

setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.original

cat << EOF >> /etc/vault.d/vault.hcl
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui=true

#mlock = true
#disable_mlock = true

storage "raft" {
  path = "/opt/vault/data"
  node_id = "$(curl http://169.254.169.254/latest/meta-data/hostname)"
}

cluster_addr = "http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8201"

listener "tcp" {
  address     = "$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"
  tls_disable = 1
}

api_addr = "http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"

seal "awskms" {
  region     = "eu-central-1"
  kms_key_id = "9827004b-2d69-4787-be2e-e5cd5ff0eee1"
}

retry_join          = ["provider=aws tag_key=Name tag_value=vault"]
EOF

systemctl --now enable vault
