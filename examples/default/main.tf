module "cluster" {
  source = "../../"
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
