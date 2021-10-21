module "cluster" {
  source = "../../"
}

output "public_ip_address" {
  value = module.cluster.aws_lb_dns_name
}
