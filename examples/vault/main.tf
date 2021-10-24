resource "aws_kms_key" "default" {
  description             = "vault"
}

output "aws_kms_key" {
  value = aws_kms_key.default.key_id
}

module "cluster" {
  source = "../../"
  name   = "vault"
  size   = "development"
  services = [
    {
      port     = 8200
      protocol = "TCP"
    }
  ]
}

output "aws_lb_dns_name" {
  value = module.cluster.aws_lb_dns_name
}
