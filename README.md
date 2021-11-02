# Terraform

This code spins up a cluster spread over availability zones, with a load balancer and a bastion host, based on a couple of variables:

- `name` - default: `"unset"`.
- `key_location` - default: `../keys/example_id_rsa.pub`.
- `region` - default: `"eu-central-1"`.
- `size` - default: `"small"`.
- `amount` - default: `3`.
- `services` - default: `[{port = 80, protocol = "HTTP"},{port=443, protocol="HTTPS"}]`.
- `user_data` - default: `user_data.sh`.

There are some more variables in `variables.tf`.

## amount

If `amount` is changed, the load balancer is also replaced, because new subnets need to be mapped. (And a new load balancer will require a new listener.)

TL;DR changing the amount gives you a load balancer address.

Please set your preferences in `terraform.tfvars`.

These settings:

```hcl
name = "my_cluster"
region = "eu-central-1"
size = "large"
amount = 5
services = [{
  port     = 443
  protocol = "TCP"
}]
```

Would create this infrastructure.

```text
 \o/      +--- loadbalaner ----+
  |  ---> | listen on: 443/tcp | ---+
 / \      +--------------------+    |
        +-------------------+-------+-----------+
        |                   |                   |
        V                   V                   V
+--- az: a -----+   +--- az: b -----+   +--- az: c -----+
| - instance: 1 |   | - instance: 2 |   | - instance: 3 |
| - instance: 4 |   | - instance: 5 |   |               |
+---------------+   +---------------+   +---------------+

+--- az: randrom ---+
| - bastion         |
+-------------------+
```

To understand the cost for this service, you can use cost.modules.tf:

```shell
terraform apply
terraform state pull | curl -s -X POST -H "Content-Type: application/json" -d @- https://cost.modules.tf/
```
