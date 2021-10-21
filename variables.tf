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
    condition     = contains(["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1"], var.region)
    error_message = "Please use \"eu-west-1\", \"eu-west-2\", \"eu-west-3\" or \"eu-central-1\"."
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

# variable "service_port" {
#   description = "What TCP or UDP port to expose."
#   type        = number
#   default     = 80
#   validation {
#     condition     = var.service_port >= 1 && var.service_port <= 65535
#     error_message = "Please use a port number between 0 and 65536."
#   }
# }
#
# variable "service_protocol" {
#   description = "The protocol to expose."
#   type        = string
#   default     = "TCP"
#   validation {
#     condition     = contains(["HTTP", "HTTPS", "TCP", "TCP_UDP", "TLS", "UDP"], var.service_protocol)
#     error_message = "Please use a protocol from this list: \"HTTP\", \"HTTPS\", \"TCP\", \"TCP_UDP\", \"TLS\" or \"UDP\"."
#   }
# }

variable "services" {
  description = "A map of ports and protocols to service."
  type        = list(any)
  default = [
    {
      port     = 80
      protocol = "HTTP"
    },
    {
      port     = 443
      protocol = "HTTPS"
    }
  ]
}

variable "user_data" {
  description = "The (bash or cloud-init) script to run on instances that are starting."
  type        = string
  default     = "user_data.sh"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_network_interface_private_ips" {
  description = "List of private IPs to assign to the ENI."
  type        = list(string)
  default     = ["172.16.10.100"]
}
