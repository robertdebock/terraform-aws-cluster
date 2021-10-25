#!/bin/bash

yum install -y yum-utils

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

yum install -y vault

setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.original

mkdir -p /vault/data
chown vault:vault /vault/data

cat << EOF >> /etc/vault.d/vault.hcl
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui=true

#mlock = true
#disable_mlock = true

storage "raft" {
  path = "/vault/data"
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
  kms_key_id = "156cb29a-b6aa-4a12-bd13-6c85f462f1b3"
  access_key = ""
  secret_key = "sHIUXLGTZqVe0FYlT+e/ZTL7fo79Ql/vjycnOBtv"
}

retry_join          = ["provider=aws tag_key=Name tag_value=vault"]
EOF

# The first instance will be able to `init` and save the root token and recovery keys.
vault operator init > /vault/data/init.txt

systemctl --now enable vault
