# output "aws_instance_public_ip" {
#   description = "The public IP address assigned to the instance."
#   value       = aws_instance.default.*.public_ip
# }

output "aws_lb_dns_name" {
  description = "The DNS name of the loadbalancer."
  value       = aws_lb.default.dns_name
}
