# ----
# LOAD BALANCER
# ----
resource "aws_lb" "example" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.subnets_in_default_vpc.ids
  security_groups    = [aws_security_group.alb_security_group.id]
}

# ----
# ELB LISTENER AND ITS RULES
# ----
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.example.arn
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

# ----
# LOAD BALANCER SECURITY GROUP
# ----
resource "aws_security_group" "alb_security_group" {
  # Use module input variables
  name = var.alb_name
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

