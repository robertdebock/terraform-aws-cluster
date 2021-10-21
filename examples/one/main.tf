module "cluster" {
  source = "../../"
  name   = "one"
  amount = "one"
}

output "public_ip_address" {
  value = module.cluster.aws_lb_dns_name
}
