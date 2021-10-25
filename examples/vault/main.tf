# # Define a policy document.
# data "aws_iam_policy_document" "default" {
#   statement {
#     sid    = "VaultAWSAuthMethod"
#     effect = "Allow"
#     actions = [
#       "ec2:DescribeInstances",
#       "iam:GetInstanceProfile",
#       "iam:GetUser",
#       "iam:GetRole",
#     ]
#     resources = ["*"]
#   }
#   statement {
#   sid    = "VaultKMSUnseal"
#   effect = "Allow"
#   actions = [
#     "kms:Encrypt",
#     "kms:Decrypt",
#     "kms:DescribeKey",
#   ]
#   resources = ["*"]
#   }
# }
#
# # Define a policy document to allow role assumption.
# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# Make a key for unsealing.
resource "aws_kms_key" "default" {
  description = "vault"
}

# # Make an IAM instance profile.
# resource "aws_iam_instance_profile" "default" {
#   name = "${var.name}-instance-profile"
#   role = aws_iam_role.default.name
# }
#
# # Make an IAM role to allow role assumption.
# resource "aws_iam_role" "default" {
#   name               = "${var.name}-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }
#
# # Bind the role to the policy.
# resource "aws_iam_role_policy" "default" {
#   name   = "${var.name}-role-policy"
#   role   = aws_iam_role.default.id
#   policy = data.aws_iam_policy_document.default.json
# }

# Find current region.
data "aws_region" "default" {}

# Write user_data.sh.
resource "local_file" "default" {
  content = templatefile("user_data.sh.tpl",
    {
      kms_key_id = aws_kms_key.default.id
      region     = data.aws_region.default.name
      name       = var.name
      access_key = var.access_key
      secret_key = var.secret_key
    }
  )
  filename             = "user_data.sh"
  file_permission      = "0640"
  directory_permission = "0755"
}

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
  # TODO: Let this module depennd on the local_file. Maybe:
  # thing = local_file.default.xyz
  # Or maybe move the local_file to a different directory.
  ]
  # This module depends on the `user_data.sh` file to be rendered, but:
  # Providers cannot be configured within modules using count, for_each or depends_on.
  #
  # When deleting the `provider` block from `../../providers.tf`:
  # The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many
  # instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends
  # on.
  #
  # As a workaround: `terrafrom apply ; terraform apply`.
  # depends_on = [
  #   local_file.default,
  # ]
}
