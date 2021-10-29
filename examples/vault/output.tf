output "vault_url" {
  value = "http://${module.cluster.aws_lb_dns_name}:8200/ui"
}

output "bastion_host_ip" {
  value = module.cluster.bastion_host_public_ip
}
