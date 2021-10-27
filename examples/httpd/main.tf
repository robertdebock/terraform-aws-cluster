module "cluster" {
  source = "../../"
  name   = "httpd"
  region = "eu-north-1"
  services = [{
    port     = 80
    protocol = "TCP"
  }]
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
