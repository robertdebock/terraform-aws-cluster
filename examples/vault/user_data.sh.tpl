#!/bin/bash

yum update -y

yum install -y yum-utils

yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

yum install -y vault-${vault_version}

setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.original

mkdir -p /vault/data
chown vault:vault /vault/data
chmod 0750 /vault/data

# 169.254.169.254 is an Amazon service to provide information about itself.
my_hostname="$(curl http://169.254.169.254/latest/meta-data/hostname)"
my_ipaddress="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"

# Place the certificate and key
echo "${tls_cert_file}" > /vault/data/vault-cert.pem
echo "${tls_key_file}" > /vault/data/vault-key.pem

cat << EOF >> /etc/vault.d/vault.hcl
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui=true

#mlock = true
#disable_mlock = true

storage "raft" {
  path = "/vault/data"
  node_id = "$${my_hostname}"
}

cluster_addr = "https://$${my_ipaddress}:8201"

listener "tcp" {
  address     = "$${my_ipaddress}:8200"
  tls_cert_file = "/vault/data/vault-cert.pem"
  tls_key_file  = "/vault/data/vault-key.pem"
}

api_addr = "https://$${my_ipaddress}:8200"

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${kms_key_id}"
  access_key = "${access_key}"
  secret_key = "${secret_key}"
}

retry_join          = ["provider=aws tag_key=Name tag_value=${name}"]
EOF

# The first instance will be able to `init` and save the root token and recovery keys.
vault operator init > /vault/data/init.txt

systemctl --now enable vault
