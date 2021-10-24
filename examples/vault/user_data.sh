#!/bin/bash

yum install -y yum-utils

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

yum install -y vault

setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

cat << EOF >> /etc/vault.d/vault.hcl
storage "raft" {
  path = "/path/to/raft/data"
  node_id = "$(curl http://169.254.169.254/latest/meta-data/hostname)"
}

cluster_addr = "$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"

listener "tcp" {
  address     = "$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"
  tls_disable = 1
}

api_addr = "http://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):8200"

# TODO: Add a aws_kms_key, refer to it here.
seal "awskms" {
  region     = "eu-cental-1"
  access_key = "a"
  secret_key = "b"
  kms_key_id = "c"
  endpoint   = "d"
}

ui=true
EOF

systemctl --now enable vault
