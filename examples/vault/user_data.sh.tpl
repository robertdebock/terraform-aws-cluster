#!/bin/bash

# Always update packages installed.
yum update -y

# Add the HashiCorp RPM repository.
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install a specific version of Vault.
yum install -y vault-${vault_version}

# Allow IPC lock capability to Vault.
setcap cap_ipc_lock=+ep $(readlink -f $(which vault))

# Make a directory for Raft, certificates and init information.
mkdir -p /vault/data
chown vault:vault /vault/data
chmod 0750 /vault/data

# 169.254.169.254 is an Amazon service to provide information about itself.
my_hostname="$(curl http://169.254.169.254/latest/meta-data/hostname)"
my_ipaddress="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"

# Place the Vault configuration.
cat << EOF > /etc/vault.d/vault.hcl
ui=true

storage "raft" {
  path = "/vault/data"
  node_id = "$${my_hostname}"
  retry_join {
    auto_join        = "provider=aws tag_key=name tag_value=${name} region=${region} access_key_id=${access_key} secret_access_key=${secret_key}"
    auto_join_scheme = "http"
  }
}

cluster_addr = "http://$${my_ipaddress}:8201"

listener "tcp" {
  address     = "$${my_ipaddress}:8200"
  tls_disable = true
}

# TODO: This should point to the loadbalancer.
api_addr = "http://$${my_ipaddress}:8200"

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${kms_key_id}"
  access_key = "${access_key}"
  secret_key = "${secret_key}"
}
EOF

# Start and enable Vault.
systemctl --now enable vault

# Make administors life a little easier.
echo "export VAULT_ADDR=http://$${my_ipaddress}:8200" >> /etc/profile

sleep 120

# TODO: Remove the `tee`, `init` produces sensitive data.
vault operator init | tee /vault/data/init.txt
