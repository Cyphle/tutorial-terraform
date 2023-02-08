provider "aws" {
  region = "eu-west-3"
}

# Terraform backend
terraform {
  backend "s3" {
    bucket = "terraform-cyphle-state-tutorial"
    # Nom du fichier state
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"

    dynamodb_table = "terraform-cyphle-state-locks"
    encrypt = true
  }
}

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

resource "aws_lb" "my_alb" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.subnets_in_default_vpc.ids
  security_groups    = [aws_security_group.alb_security_group.id]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_my_alb.arn
  }
}

resource "aws_security_group" "alb_security_group" {
  name = "terraform-example-alb"

  # Allow inbount HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target group for ALB to point to ASG
resource "aws_lb_target_group" "tg_my_alb" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

