# This module creates security groups for the ALB and ECS services.

# Security group for the Application Load Balancer (ALB)
resource "aws_security_group" "ALB-SG" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "ALB-SG"
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
resource "aws_security_group" "ECS-SG" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "ECS-SG"
    }
  )

# Ingress rule to allow traffic from the ALB security group on port 8000
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_groups = [aws_security_group.ALB-SG.id]
  }

# Egress rule to allow all outbound traffic from the ECS service
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}