module "cluster" {
  source = "../../"
  name   = "consul"
  region = "eu-central-1"
  size   = "development"
  services = [
    {
      port     = 8600
      protocol = "TCP_UDP"
    }
  ]
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
