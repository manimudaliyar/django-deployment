output "ecs-execution-role-arn" {
  value = aws_iam_role.ecs-execution-role.arn
  description = "ARN of the IAM role for ECS task execution"
}

output "ecs-task-role-arn" {
  value = aws_iam_role.ecs-task-role.arn
  description = "ARN of the IAM role for the ECS task role"
}