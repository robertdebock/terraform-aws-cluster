# Vault

Spin up a HashiCorp Vault cluster that automatically unseals and members joins based on AWS tags.

## Setup

```shell
terraform init
test -f id_rsa.pub || ssh-keygen -f id_rsa
```

Generate (or place) the SSL keys and certificates.

```shell
# Make a directory.
mkdir files/

# Create a private key for the ca.
openssl genrsa -out files/ca.key 2048

# Create certificate for the ca.
openssl req -x509 -new -nodes -key files/ca.key -sha256 -days 1825 -out files/ca.pem

# Create a private key for the service.
openssl genrsa -out files/vault.key 2048

# Create CSR for the service.
openssl req -new -key files/vault.key -out files/vault.csr

openssl x509 -req -in files/vault.csr -CA files/ca.pem -CAkey files/ca.key -CAcreateserial \
-out files/vault.crt -days 825 -sha256
```

## KMS auto-unsealing

To use the AWS KMS Key, Vault needs to be able to read the kms key.
Set these variables, used in user_data.sh.tpl.

```shell
export TF_VAR_access_key=${AWS_ACCESS_KEY_ID}
export TF_VAR_secret_key=${AWS_SECRET_ACCESS_KEY}
```

## Deploying

First create the `user_data.sh` file. This is required, because the module consumes `user_data.sh`, but a dependency can't be created.

```shell
terraform apply -target local_file.default
```

Note: the file `user_data.sh` requires the `aws_kms_key` to be generated too, which is done automatically.

Next deploy all resources:

```shell
terraform apply
```
