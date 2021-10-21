# Default

Spin up a Apache httpd cluster with a custom script: `user_data.sh`. The `user_data.sh` will install an Apache httpd webserver.

Basically just for development and testing.

## Setup

```shell
terraform init
```

## Running

```shell
terraform apply
```

The output contains the hostname for the load balancer entry point.

## Cleanup

```shell
terraform destroy
```
