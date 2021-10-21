module "cluster" {
  source = "../../"
  name   = "vault-3"
  size   = "development"
  services = [
    {
      port     = 8200
      protocol = "TCP"
    }
  ]
}

output "public_ip_address" {
  value = module.cluster.aws_lb_dns_name
}
