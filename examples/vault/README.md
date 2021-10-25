# Vault

Spin up a HashiCorp Vault cluster that automatically unseals and members joins based on AWS tags.

## Setup

```shell
terraform init
test -f id_rsa.pub || ssh-keygen -f id_rsa
```

## KMS auto-unsealing

To use the AWS KMS Key, Vault needs to be able to read the kms key.
Set these variables, used in user_data.sh.tpl.

```shell
export TF_VAR_access_key=${AWS_ACCESS_KEY_ID}
export TF_VAR_secret_key=${AWS_SECRET_ACCESS_KEY}
```
