output "django-secret-arn" {
  value = aws_secretsmanager_secret.django-ecs-secret.arn
  description = "ARN of the Secrets Manager secret for the Django ECS task"
}