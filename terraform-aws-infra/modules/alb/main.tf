# =============================================================================
# Module: ALB
# =============================================================================
# This module provisions the Application Load Balancer and related resources
# for routing external traffic to ECS Fargate tasks.
#
# Resources created:
#   - Application Load Balancer — internet-facing, placed in public subnets
#   - Target Group              — routes traffic to ECS tasks on port 8000
#                                 target_type = "ip" required for Fargate
#   - Listener                  — listens on port 80, forwards to target group
#
# Traffic flow:
#   Internet → ALB (port 80) → Target Group (port 8000) → ECS Fargate tasks
#
# Note:
#   HTTPS (port 443) is not configured as this is a demo deployment
#   without a custom domain or ACM certificate.
#   Target group name has a 32 character AWS limit — keep environment name short.
#
# Inputs:  environment, project-owner, vpc-id, alb-sg-id,
#          public-subnet-1, public-subnet-2
# Outputs: alb-dns-name, target-group-arn
# =============================================================================

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