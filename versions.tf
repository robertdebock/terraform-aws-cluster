terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.62.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    template = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
