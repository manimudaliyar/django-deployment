# =============================================================================
# Module: IAM
# =============================================================================
# This module provisions IAM roles and policies for ECS Fargate and
# GitHub Actions OIDC authentication.
#
# Resources created:
#   - ECS Task Execution Role — used by ECS to bootstrap the container
#                               (pull image from ECR, create CloudWatch log streams)
#                               Attached policy: AmazonECSTaskExecutionRolePolicy (AWS managed)
#
#   - ECS Task Role           — used by the Django app at runtime
#                               (fetch secrets from Secrets Manager)
#                               Attached policy: custom secrets-manager-policy
#
#   - GitHub Actions OIDC Provider — establishes trust between GitHub Actions
#                                    and AWS via OpenID Connect
#
#   - GitHub Actions OIDC Role — assumed by GitHub Actions via OIDC
#                                scoped to a specific GitHub repository
#                                Attached policies: AmazonEC2ContainerRegistryPowerUser,
#                                                   AdministratorAccess (scoped in production)
#
# Key distinction:
#   Execution Role = ECS uses this BEFORE the container starts
#   Task Role      = Django app uses this WHILE the container is running
#   OIDC Role      = GitHub Actions assumes this to run Terraform and deploy to ECS
#
# Trust policies:
#   ECS roles    → trust ecs-tasks.amazonaws.com via sts:AssumeRole
#   OIDC role    → trust token.actions.githubusercontent.com via sts:AssumeRoleWithWebIdentity
#                  scoped to repo:manimudaliyar/django-deployment:*
#
# Inputs:  environment, project-owner, github-repo
# Outputs: ecs-execution-role-arn, ecs-task-role-arn, gha-oidc-role-arn
# =============================================================================

# Policy document for ECS task execution role trust relationship
data "aws_iam_policy_document" "ecs-trust-policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Policy document for ECS task role to allow access to Secrets Manager
data "aws_iam_policy_document" "secrets-manager-policy" {
  statement {
    effect = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs-execution-role" {
    name = "${var.environment}-ecs-execution-role"
    assume_role_policy = data.aws_iam_policy_document.ecs-trust-policy.json
    tags = merge(
        local.common_tags,
        {
        Name = "${var.environment}-ecs-execution-role"
        }
    )
}

# IAM role for ECS task role
resource "aws_iam_role" "ecs-task-role" {
    name = "${var.environment}-ecs-task-role"
    assume_role_policy = data.aws_iam_policy_document.ecs-trust-policy.json
    tags = merge(
        local.common_tags,
        {
        Name = "${var.environment}-ecs-task-role"
        }
    )
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS execution role
resource "aws_iam_role_policy_attachment" "execution-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role = aws_iam_role.ecs-execution-role.name
}

# Create a custom policy for Secrets Manager access and attach it to the ECS task role
resource "aws_iam_policy" "secrets-manager-policy" {
  name = "${var.environment}-secrets-manager-policy"
  policy = data.aws_iam_policy_document.secrets-manager-policy.json
}

# Attach the custom Secrets Manager policy to the ECS task role
resource "aws_iam_role_policy_attachment" "task-role-attachment" {
    role = aws_iam_role.ecs-task-role.name
    policy_arn = aws_iam_policy.secrets-manager-policy.arn
}

resource "aws_iam_openid_connect_provider" "gha-oidc-provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [ "sts.amazonaws.com" ]
  thumbprint_list = [ "6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd" ]
}

data "aws_iam_policy_document" "gha-trust-policy" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    principals {
      type = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.gha-oidc-provider.arn ]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [ var.github-repo ]
    }
  }
}

resource "aws_iam_role" "gha-oidc-role" {
  name = "${var.environment}-gha-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.gha-trust-policy.json
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-gha-oidc-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "gha-terraform-policy" {
  role = aws_iam_role.gha-oidc-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}