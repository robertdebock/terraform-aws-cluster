# Make a key for unsealing.
resource "aws_kms_key" "default" {
  description = "vault"
}

# Find current region.
data "aws_region" "default" {}

# Write user_data.sh.
resource "local_file" "default" {
  content = templatefile("user_data.sh.tpl",
    {
      kms_key_id    = aws_kms_key.default.id
      region        = data.aws_region.default.name
      name          = var.name
      access_key    = var.access_key
      secret_key    = var.secret_key
      vault_version = var.vault_version
      tls_cert_file = file("vault-cert.pem")
      tls_key_file  = file("vault-key.pem")
    }
  )
  filename             = "user_data.sh"
  file_permission      = "0640"
  directory_permission = "0755"
}

# Call the cluster module.
module "cluster" {
  source = "../../"
  name   = var.name
  size   = "development"
  region = var.region
  services = [
    {
      port     = 8200
      protocol = "TCP"
    }
  ]
}
