module "cluster" {
  source = "../../"
  tags = {
    owner    = "robertdebock"
  }
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
