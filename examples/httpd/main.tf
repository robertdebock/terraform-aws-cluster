module "cluster" {
  source = "../../"
  name   = "httpd"
  size   = "development"
  services = [{
    port     = 80
    protocol = "TCP"
  }]
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
