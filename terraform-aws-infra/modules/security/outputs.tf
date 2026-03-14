# ALB-SG-ID output to provide the security group ID of the ALB security group
output "ALB-SG-ID" {
   value = aws_security_group.ALB-SG.id
}

# ECS-SG-ID output to provide the security group ID of the ECS service security group
output "ECS-SG-ID" {
   value = aws_security_group.ECS-SG.id
}