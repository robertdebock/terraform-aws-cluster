module "cluster" {
  source = "../../"
  name   = "httpd"
  region = "eu-north-1"
  size   = "development"
  services = [{
    port     = 80
    protocol = "TCP"
  }]
  tags = {
    owner    = "robertdebock"
  }
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}

output "bastion_host_ip" {
  value = module.cluster.bastion_host_public_ip
}
