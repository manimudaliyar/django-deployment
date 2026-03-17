# =============================================================================
# Module: Security
# =============================================================================
# This module provisions security groups for the ALB and ECS Fargate tasks.
#
# Resources created:
#   - ALB Security Group  — allows inbound HTTP (80) and HTTPS (443) from anywhere
#                         — allows all outbound traffic
#   - ECS Security Group  — allows inbound on port 8000 from ALB SG only
#                         — allows all outbound traffic (ECR, Secrets Manager, CloudWatch)
#
# Security model:
#   Internet → ALB SG (port 80/443) → ECS SG (port 8000)
#   ECS tasks are not directly reachable from the internet.
#   All inbound traffic to ECS must pass through the ALB.
#
# Inputs:  vpc-id
# Outputs: alb-sg-id, ecs-sg-id
# =============================================================================

# This module creates security groups for the ALB and ECS services.

# Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "alb-sg" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "alb-sg"
    }
  )

# Ingress rules for ALB to allow HTTP and HTTPS traffic from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Egress rule to allow all outbound traffic from the ALB
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the ECS service
resource "aws_security_group" "ecs-sg" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "ecs-sg"
    }
  )

# Ingress rule to allow traffic from the ALB security group on port 8000
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

# Egress rule to allow all outbound traffic from the ECS service
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}