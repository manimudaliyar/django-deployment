# ALB module for Django deployment
resource "aws_alb" "django-alb" {
  name = "${var.environment}-django-alb"
  security_groups = [var.alb-sg-id]
  subnets = [var.public-subnet-1, var.public-subnet-2]
  internal = false
  load_balancer_type = "application"
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-alb"
    }
  )
}

# ALB Target Group for Django application
resource "aws_alb_target_group" "django-alb-tg" {
  name = "${var.environment}-django-alb-tg"
  port = 8000
  protocol = "HTTP"
  vpc_id = var.vpc-id
  target_type = "ip"
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-alb-tg"
    }
  )
}

# ALB Listener for Django application
resource "aws_alb_listener" "django-alb-listener" {
  load_balancer_arn = aws_alb.django-alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.django-alb-tg.arn
  }
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-alb-listener"
    }
  )
}