resource "aws_autoscaling_group" "myasg" {
  launch_configuration = aws_launch_configuration.aninstance.name
  # Launch in all subnets found
  vpc_zone_identifier = data.aws_subnets.subnets_in_default_vpc.ids

  # Bind to same target group of ELB
  target_group_arns = [aws_lb_target_group.tg_my_alb.arn]
  # Delegate health check to ELB instead of EC2 by default
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
