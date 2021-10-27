output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}

output "vault_url" {
  value = "https://${module.cluster.aws_lb_dns_name}:8200/ui"
}
