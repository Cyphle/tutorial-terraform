resource "aws_autoscaling_group" "myasg" {
  # For 0 downtime deployment name depends on launch configuration in order to be updated
  # name = "${var.cluster_name}-${aws_launch_configuration.aninstance.name}"
  name = var.cluster_name

  launch_configuration = aws_launch_configuration.aninstance.name
  # Launch in all subnets found
  vpc_zone_identifier = data.aws_subnets.subnets_in_default_vpc.ids

  # Bind to same target group of ELB
  target_group_arns = [aws_lb_target_group.tg_my_alb.arn]
  # Delegate health check to ELB instead of EC2 by default
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  # For 0 downtime deployment, wait for at least this many instances to pass health checks before considering ASG deployment complete
  # min_elb_capacity = var.min_size

  # For 0 downtime deployment, when replacing ASG, create replacement first and only delete the original after
  # lifecycle {
  #   create_before_destroy = true
  # }

  # Solution AWS pour faire du 0 downtime avec le même nombre de replicas qu'originalement
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

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

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  # Conditional avec count. Si 1, resource, si 0 pas de resource
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
