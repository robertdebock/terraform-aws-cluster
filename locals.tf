locals {
  # TODO: idea, decide instance amount based on cluster type?
  #
  # _instance_amount = {
  #   development = 1
  #   small = 3
  #   large = 5
  #   maximum = 7
  # }
  # instance_amount = local._instance_amount[var.size]

  _instance_type = {
    development = "t3.micro"
    minimum     = "m5.large"
    small       = "m5.xlarge"
    large       = "m5.2xlarge"
    maximum     = "m5.4xlarge"
  }
  instance_type = local._instance_type[var.size]

  _volume_size = {
    development = 1
    minimum     = 50
    small       = 50
    large       = 100
    maximum     = 100
  }
  volume_size = local._volume_size[var.size]

  _instance_ami = {
    eu-central-1 = "ami-0233214e13e500f77"
    eu-west-1    = "ami-047bb4163c506cd98"
    eu-west-2    = "ami-f976839e"
    eu-west-3    = "ami-0ebc281c20e89ba4b"
  }
  instance_ami = local._instance_ami[var.region]

  _associate_public_ip_address = {
    development = true
    minimum     = false
    small       = false
    large       = false
    maximum     = false
  }
  associate_public_ip_address = local._associate_public_ip_address[var.size]

  # health_check.protocol can be one of [HTTP HTTPS TCP].
  _health_check = {
    HTTP    = "HTTP"
    HTTPS   = "HTTPS"
    TCP_UDP = "TCP"
    TLS     = "TCP"
    UDP     = "TCP" # Healthchecking is not possible for UDP.
  }
}
