# Create one VPC.
resource "aws_vpc" "default" {
  cidr_block = var.aws_vpc_cidr_block
  tags       = var.tags
}

# Create an internet gateway.
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags   = var.tags
}

# Create a routing table for the internet gateway.
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
}

# Add an internet route to the internet gateway.
resource "aws_route" "default" {
  route_table_id         = aws_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create the same amount of subnets as the amount of instances.
resource "aws_subnet" "default" {
  count             = min(length(data.aws_availability_zones.default.names), var.amount)
  vpc_id            = aws_vpc.default.id
  cidr_block        = "172.16.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.default.names[count.index]
  tags              = var.tags
}

# Associate the subnet to the routing table.
resource "aws_route_table_association" "default" {
  count = min(length(data.aws_availability_zones.default.names), var.amount)
  subnet_id      = aws_subnet.default[count.index].id
  route_table_id = aws_route_table.default.id
}

# Find availability_zones in this region.
data "aws_availability_zones" "default" {
  state = "available"
}

# Place an SSH key.
resource "aws_key_pair" "default" {
  count      = fileexists(var.key_location) ? 1 : 0
  key_name   = var.name
  public_key = file(var.key_location)
  tags       = var.tags
}

# Find amis.
data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Create a security group.
resource "aws_security_group" "default" {
  name   = var.name
  vpc_id = aws_vpc.default.id
  tags   = var.tags
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

# Allow access from the bastion host.
resource "aws_security_group_rule" "ssh" {
  description       = "ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = [var.aws_vpc_cidr_block]
  security_group_id = aws_security_group.default.id
}

# Allow internet from the instances. Required for package installations.
resource "aws_security_group_rule" "internet" {
  description       = "internet"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Create a launch template.
resource "aws_launch_configuration" "default" {
  name_prefix                 = "${var.name}"
  image_id                    = data.aws_ami.default.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.default[0].id
  security_groups             = [aws_security_group.default.id]
  user_data                   = fileexists(var.user_data) ? filebase64(var.user_data) : filebase64("${path.module}/user_data.sh")
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

# Create a placement group that spreads over racks.
resource "aws_placement_group" "default" {
  name     = var.name
  strategy = "spread"
  tags     = var.tags
}

# Add a load balancer.
resource "aws_lb" "default" {
  name               = var.name
  load_balancer_type = "network"
  subnets            = aws_subnet.default.*.id
  tags               = var.tags
}

# Create a load balancer target group.
resource "aws_lb_target_group" "default" {
  count    = length(var.services)
  name     = "${var.name}-${count.index}"
  port     = var.services[count.index].port
  protocol = var.services[count.index].protocol
  vpc_id   = aws_vpc.default.id
  tags     = var.tags
  health_check {
    protocol            = local._aws_lb_target_group_health_check_protocol[var.services[count.index].protocol]
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
  tags              = var.tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[count.index].arn
  }
}

# Create an auto scaling group.
resource "aws_autoscaling_group" "default" {
  name                  = var.name
  desired_capacity      = var.amount
  min_size              = var.amount - 1
  max_size              = var.amount + 2
  health_check_type     = "ELB"
  placement_group       = aws_placement_group.default.id
  max_instance_lifetime = var.aws_autoscaling_group_max_instance_lifetime
  vpc_zone_identifier   = tolist(aws_subnet.default[*].id)
  target_group_arns     = tolist(aws_lb_target_group.default[*].arn)
  launch_configuration  = aws_launch_configuration.default.name
  tag {
    key                 = "name"
    value               = var.name
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create one security group in the single VPC.
resource "aws_security_group" "bastion" {
  count  = var.bastion_host ? 1 : 0
  name   = "${var.name}-bastion"
  vpc_id = aws_vpc.default.id
  tags   = var.tags
}

# Allow SSH to the security group.
resource "aws_security_group_rule" "bastion-ssh" {
  count             = var.bastion_host ? 1 : 0
  description       = "ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion[0].id
}

# Allow internet access.
resource "aws_security_group_rule" "bastion-internet" {
  count             = var.bastion_host ? 1 : 0
  description       = "internet"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion[0].id
}

# Create the bastion host.
resource "aws_instance" "bastion" {
  count                       = var.bastion_host ? 1 : 0
  ami                         = data.aws_ami.default.id
  subnet_id                   = aws_subnet.default[0].id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.bastion[0].id]
  key_name                    = aws_key_pair.default[0].id
  associate_public_ip_address = true
  monitoring                  = true
  tags                        = var.tags
}
