module "cluster" {
  source = "../../"
  name   = "single"
  amount = 1
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
