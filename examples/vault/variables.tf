# Because we create and read a few resources and values before using the module,
# the region needs to be set.
variable "region" {
  description = "The region to deploy to."
  type        = string
  default     = "eu-central-1"
  validation {
    condition     = contains(["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1"], var.region)
    error_message = "Please use \"eu-west-1\", \"eu-west-2\", \"eu-west-3\" or \"eu-central-1\"."
  }
}

# The module will need a `name`, and for rendering the `user_data.sh` file, the
# name is also required. This variable is simply passed to the module.
variable "name" {
  description = "The name of the project in 3 to 8 characters."
  type        = string
  default     = "vault"
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 8 && var.name != "default"
    error_message = "Please use a minimum of 3 and a maximum of 8 characters. \"default\" can't be used because it is reserved."
  }
}

variable "vault_version" {
  description = "The version of Vault to install."
  type        = string
  default     = "1.8.4"
  validation {
    condition     = length(var.vault_version) == 5 && can(regex("^1\\.", var.vault_version))
    error_message = "Please use a SemVer version, where the major version is \"1\"."
  }
}

# To read the unseal key, the AWS access key and AWS secret key need to be placed in the Vault configuration.
variable "access_key" {
  description = "The AWS access key. You can set a variable TF_VAR_aws_access_key."
  type        = string
}

variable "secret_key" {
  description = "The AWS secret key. You can set a variable TF_VAR_aws_secret_key."
  type        = string
}
