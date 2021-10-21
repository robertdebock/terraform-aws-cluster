module "cluster" {
  source = "../../"
  name   = "consul-3"
  region = "eu-central-1"
  size   = "development"
  services = [
    {
      port     = 8600
      protocol = "TCP_UDP"
    }
  ]
}

output "public_ip_address" {
  value = module.cluster.aws_lb_dns_name
}
