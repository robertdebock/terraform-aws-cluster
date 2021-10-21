module "cluster" {
  source = "../../"
  name   = "httpd-3"
}

output "public_ip_address" {
  value = module.cluster.aws_lb_dns_name
}
