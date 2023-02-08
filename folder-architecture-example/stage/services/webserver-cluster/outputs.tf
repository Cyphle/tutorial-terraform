output "alb_dns_name" {
  value       = aws_lb.my_alb.dns_name
  description = "The domain name of the load balancer"
}