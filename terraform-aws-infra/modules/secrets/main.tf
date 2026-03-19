
# Secrets Manager Secret for ECS Task 
resource "aws_secretsmanager_secret" "django-ecs-secret" {
  name = "${var.environment}-django-ecs-secret"
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-ecs-secret"
    }
  )
}

# Secret Version for ECS Task
resource "aws_secretsmanager_secret_version" "django-ecs-secret-version" {
  secret_id = aws_secretsmanager_secret.django-ecs-secret.id
  secret_string = jsonencode({
    DJANGO_SECRET_KEY = var.django-secret-key
  })
}