# Default

Spin up a cluster. Because there is no `user_data.sh`, these machines will not provide any service.

Basically just for development.

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
