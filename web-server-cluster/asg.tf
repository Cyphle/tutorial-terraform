
resource "aws_launch_configuration" "aninstance" {
  image_id        = "ami-0ca5ef73451e16dc1"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.mysg.id]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
        EOF

  # Required when using a launch configuration with an ASG
  # As Terraform is immutable, if any change is applied, it will delete everything. As it is monitored by ASG
  # use lifecycle settings to tell Terraform to create new things before deleting old ones.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mysg" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "myasg" {
  launch_configuration = aws_launch_configuration.aninstance.name
  # Launch in all subnets found
  vpc_zone_identifier = data.aws_subnets.subnets_in_default_vpc.ids

  # Bind to same target group of ELB
  target_group_arns = [aws_lb_target_group.tg_my_alb.arn]
  # Delegate health check to ELB instead of EC2 by default
  health_check_type = "ELB"

  min_size = 1
  max_size = 3

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
