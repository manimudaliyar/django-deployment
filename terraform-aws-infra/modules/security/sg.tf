resource "aws_security_group" "ALB-SG" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "ALB-SG"
    }
  )

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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ECS-SG" {
  vpc_id = var.vpc-id
  tags = merge(
    local.common_tags,
    {
    Name = "ECS-SG"
    }
  )

  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    security_groups = [aws_security_group.ALB-SG.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}