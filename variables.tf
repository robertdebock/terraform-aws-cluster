variable "name" {
  description = "The name of the project in 3 to 8 characters."
  type        = string
  default     = "unset"
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 8 && var.name != "default"
    error_message = "Please use a minimum of 3 and a maximum of 8 characters. \"default\" can't be used because it is reserved."
  }
}

variable "key_location" {
  description = "The location of the public key"
  default     = "id_rsa.pub"
}

variable "region" {
  description = "The region to deploy to."
  type        = string
  default     = "eu-central-1"
  validation {
    condition     = contains(["eu-central-1", "eu-north-1", "eu-south-1", "eu-west-1", "eu-west-2", "eu-west-3", ], var.region)
    error_message = "Please use \"eu-central-1\", \"eu-north-1\", \"eu-south-1\", \"eu-west-1\", \"eu-west-2\" or \"eu-west-3\"."
  }
}

variable "size" {
  description = "The size of the deployment."
  type        = string
  default     = "small"
  validation {
    condition     = contains(["development", "minimum", "small", "large", "maximum"], var.size)
    error_message = "Please use \"development\", \"minimum\", \"small\", \"large\" or \"maximum\"."
  }
}

variable "amount" {
  description = "The amount of instances to deploy."
  type        = number
  default     = 3
  validation {
    condition     = var.amount % 2 == 1
    error_message = "Please use an odd number for amount, like 1, 3 or 5."
  }
}

variable "services" {
  description = "A map of ports and protocols to service."
  type        = list(any)
  default = [
    {
      port     = 80
      protocol = "TCP"
    },
    {
      port     = 443
      protocol = "TCP"
    }
  ]
}

variable "user_data" {
  description = "The (bash or cloud-init) script to run on instances that are starting."
  type        = string
  default     = "user_data.sh"
}

variable "bastion_host" {
  description = "A bastion host is optional and would allow you to login to the instances."
  type        = bool
  default     = true
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_subnet_public_cidr_block" {
  description = "The CIDR block for the public subnet."
  type        = string
  default     = "172.16.254.0/24"
}

variable "tags" {
  default     = {
    owner = "unset"
  }
  description = "Tags to add to resources."
  type        = map(string)
}

variable "aws_autoscaling_group_max_instance_lifetime" {
  description = "The amount of seconds after which to replace the instances."
  type        = number
  default     = 86400
  validation {
    condition     = var.aws_autoscaling_group_max_instance_lifetime == 0 || (var.aws_autoscaling_group_max_instance_lifetime >= 86400 && var.aws_autoscaling_group_max_instance_lifetime <= 31536000)
    error_message = "Use \"0\" to remove the parameter or a value between \"86400\" and \"31536000\"."
  }
}
