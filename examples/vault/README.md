# Vault

Spin up a HashiCorp Vault cluster that automatically unseals and members joins based on AWS tags.

## Setup

```shell
terraform init
test -f id_rsa.pub || ssh-keygen -f id_rsa
```

## KMS auto-unsealing & automatic joining.

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
