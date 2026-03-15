# ALB-SG-ID output to provide the security group ID of the ALB security group
output "alb-sg-id" {
   value = aws_security_group.alb-sg.id
}

# ECS-SG-ID output to provide the security group ID of the ECS service security group
output "ecs-sg-id" {
   value = aws_security_group.ecs-sg.id
}