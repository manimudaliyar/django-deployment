# =============================================================================
# Module: Secrets
# =============================================================================
# This module provisions AWS Secrets Manager resources for the Django ECS task.
#
# Resources created:
#   - Secrets Manager Secret         — creates the secret container in AWS
#   - Secrets Manager Secret Version — stores the actual secret values
#
# Secrets stored:
#   - DJANGO_SECRET_KEY — Django application secret key
#
# Security model:
#   - Secret values are never hardcoded in Terraform code or tfvars
#   - Values are passed at runtime via -var flag from GitHub Actions
#   - GitHub Actions reads values from repository secrets
#   - ECS task fetches secrets at runtime via task role (secretsmanager:GetSecretValue)
#
# Flow:
#   GitHub Secrets → -var flag → Terraform → Secrets Manager → ECS Task at runtime
#
# Inputs:  environment, project-owner, django-secret-key (sensitive)
# Outputs: secret-arn
# =============================================================================


# Secrets Manager Secret for ECS Task 
resource "aws_secretsmanager_secret" "django-ecs-secret" {
  name = "${var.environment}-django-ecs-secret"
  recovery_window_in_days = 0 # Immediate deletion, no recovery window
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