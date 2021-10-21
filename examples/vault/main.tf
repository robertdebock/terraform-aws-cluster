module "cluster" {
  source = "../../"
  name   = "vault"
  size   = "development"
  services = [
    {
      port     = 8200
      protocol = "TCP"
    }
  ]
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
