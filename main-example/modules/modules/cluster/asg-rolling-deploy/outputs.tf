output "asg_name" {
  value       = aws_autoscaling_group.myasg.name
  description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
  value       = aws_security_group.mysg.id
  description = "The ID of the EC2 Instance Security Group"
}
