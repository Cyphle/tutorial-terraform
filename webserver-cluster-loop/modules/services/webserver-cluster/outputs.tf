output "alb_dns_name" {
  value       = aws_lb.my_alb.dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.myasg
  description = "The name of the Auto Scaling Group"
}

output "alb_security_group_id" {
  value      = aws_security_group.alb_security_group.id
  description = "The ID of the security group attached to the load balancer"
}
