resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb-${var.path}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.network.public_subnet_ids

  tags = {
    Path = var.path
  }
}

# Target Group

resource "aws_lb_target_group" "target_group" {
  name        = "${var.name_prefix}-tg-${var.path}"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.network.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Path = var.path
  }
}

# Listener

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}