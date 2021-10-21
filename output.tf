output "aws_lb_dns_name" {
  description = "The DNS name of the loadbalancer."
  value       = aws_lb.default.dns_name
}
