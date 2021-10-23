# Find amis.
data "aws_ami" "default" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

# Add a load balancer.
resource "aws_lb" "default" {
  name               = var.name
  load_balancer_type = "network"
  dynamic "subnet_mapping" {
    for_each = aws_subnet.default.*
    content {
      subnet_id = aws_subnet.default[subnet_mapping.key].id
    }
  }
}

# Create a load balancer target group.
resource "aws_lb_target_group" "default" {
  count    = length(var.services)
  name     = "${var.name}-${count.index}"
  port     = var.services[count.index].port
  protocol = var.services[count.index].protocol
  vpc_id   = aws_vpc.default.id
  health_check {
    protocol            = var.services[count.index].protocol
    healthy_threshold   = 10
    unhealthy_threshold = 10
  }
}

# Add a listener to the loadbalancer.
resource "aws_lb_listener" "default" {
  count             = length(var.services)
  load_balancer_arn = aws_lb.default.arn
  port              = var.services[count.index].port
  protocol          = local._listener_protocol[var.services[count.index].protocol]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[count.index].arn
  }
}

# Create a placement group that spreads over racks.
resource "aws_placement_group" "default" {
  name     = var.name
  strategy = "spread"
  # TODO: on `destroy`: Error: InvalidPlacementGroup.InUse: The placement group 'mine' is in use and may not be deleted.
}

# Create a launch template.
resource "aws_launch_template" "default" {
  name                                 = var.name
  update_default_version               = true
  image_id                             = data.aws_ami.default.id

  instance_type                        = local.instance_type
  ebs_optimized                        = true
  disable_api_termination              = true
  key_name                             = aws_key_pair.default[0].id
  instance_initiated_shutdown_behavior = "terminate"
  user_data                            = fileexists(var.user_data) ? filebase64(var.user_data) : filebase64("${path.module}/user_data.sh")
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = local.volume_size
    }
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  credit_specification {
    cpu_credits = "standard"
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = local.associate_public_ip_address
    security_groups             = [aws_security_group.default.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group.
resource "aws_autoscaling_group" "default" {
  name                  = var.name
  desired_capacity      = var.amount
  min_size              = var.amount
  max_size              = var.amount + 2
  health_check_type     = "ELB"
  placement_group       = aws_placement_group.default.id
  max_instance_lifetime = 1 * 24 * 60 * 60
  vpc_zone_identifier   = tolist(aws_subnet.default[*].id)
  target_group_arns     = tolist(aws_lb_target_group.default[*].arn)
  launch_template {
    id      = aws_launch_template.default.id
    version = aws_launch_template.default.latest_version
  }
  timeouts {
    delete = "15m"
  }
  tag {
    key                 = "name"
    value               = var.name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Place an SSH key.
resource "aws_key_pair" "default" {
  count = fileexists(var.key_location) ? 1 : 0
  key_name   = var.name
  public_key = file(var.key_location)
}

# Create one VPC.
resource "aws_vpc" "default" {
  cidr_block = var.aws_vpc_cidr_block
  tags       = {}
}

# Create one internet gateway.
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags   = {}
}

# Add a routing table to the default routing table.
resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.default.default_route_table_id
  route = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.default.id
      # Due to an issue, these parameters need to be specified, even though they may be empty.
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  ]
  tags = {}
}

# Find availability_zones in this region.
data "aws_availability_zones" "default" {
  state = "available"
}

# Create the same amount of subnets as the amount of instances.
resource "aws_subnet" "default" {
  count             = min(length(data.aws_availability_zones.default.names), var.amount)
  vpc_id            = aws_vpc.default.id
  cidr_block        = "172.16.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.default.names[count.index]
  tags              = {}
}

# Create one security group in the single VPC.
resource "aws_security_group" "default" {
  name   = var.name
  vpc_id = aws_vpc.default.id
}

# Allow SSH to the security group.
resource "aws_security_group_rule" "ssh" {
  count             = var.size == "development" ? 1 : 0
  description       = "ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow the service to be accessed.
resource "aws_security_group_rule" "service" {
  count             = length(var.services)
  description       = "service-${count.index}"
  type              = "ingress"
  from_port         = var.services[count.index].port
  to_port           = var.services[count.index].port
  protocol          = local._security_group_rule_protocol[var.services[count.index].protocol]
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow internet from the instances. Required for package installation.
resource "aws_security_group_rule" "internet" {
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
