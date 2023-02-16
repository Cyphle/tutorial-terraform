# ----
# LOAD BALANCER
# ----
resource "aws_lb" "my_alb" {
  name               = "${var.cluster_name}-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.subnets_in_default_vpc.ids
  security_groups    = [aws_security_group.alb_security_group.id]
}

# ----
# ELB LISTENER AND ITS RULES
# ----
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = local.http_port
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

# ----
# LOAD BALANCER SECURITY GROUP
# ----
resource "aws_security_group" "alb_security_group" {
  # Use module input variables
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_security_group.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_security_group.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# ----
# LOAD BALANCER TARGET GROUP
# ----
# Target group for ALB that will be used in ASG resource configuration
resource "aws_lb_target_group" "tg_my_alb" {
  name     = "${var.cluster_name}-tg"
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
