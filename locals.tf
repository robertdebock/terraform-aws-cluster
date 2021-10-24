locals {

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

  _associate_public_ip_address = {
    development = true
    minimum     = false
    small       = false
    large       = false
    maximum     = false
  }
  associate_public_ip_address = local._associate_public_ip_address[var.size]

  # aws_lb_target_group.protocol can be:
  # GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP.

  # aws_alb_target_group.health_check.protocol can be:
  # HTTP, HTTPS or TCP.

  _aws_lb_target_group_health_check_protocol = {
    GENEVE  = "TCP"
    HTTP    = "HTTP"
    HTTPS   = "HTTPS"
    TCP     = "TCP"
    TCP_UDP = "TCP"
    TLS     = "HTTPS"
    UDP     = "TCP" # How owtherwise to check?
  }

  # aws_lb_target_group.protocol can be:
  # GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP.

  # aws_lb_listener.protocol can be:
  # TCP, TLS, UDP, and TCP_UDP.

  # Maps protocols from aws_lb_target_group to aws_lb_listerer
  _listener_protocol = {
    GENEVE  = "TCP"
    HTTP    = "TCP"
    HTTPS   = "TLS"
    TCP     = "TCP"
    TCP_UDP = "TCP_UDP"
    TLS     = "TLS"
    UDP     = "UDP"
  }

  # aws_lb_target_group.protocol can be:
  # GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP.

  # aws_securityu_group_rule.protocol can be:
  # icmp, icmpv6, tcp, udp, all or use the protocol number.

  # Maps protocols from aws_lb_target_group to security_group_rule.
  _security_group_rule_protocol = {
    GENEVE  = "TCP"
    HTTP    = "TCP"
    HTTPS   = "TCP"
    TCP     = "TCP"
    TCP_UDP = "TCP"
    TLS     = "TCP"
    UDP     = "UDP"
  }
}
