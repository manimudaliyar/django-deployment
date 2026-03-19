# =============================================================================
# Bootstrap: GitHub Actions OIDC Authentication
# =============================================================================
# This configuration is applied ONCE manually from a local machine.
# It establishes the trust relationship between GitHub Actions and AWS
# via OpenID Connect, enabling keyless authentication in CI/CD pipelines.
#
# Resources created:
#   - OIDC Provider   — registers GitHub Actions as a trusted identity provider
#                       in AWS (token.actions.githubusercontent.com)
#   - GHA OIDC Role   — IAM role assumed by GitHub Actions via OIDC
#                       scoped to a specific GitHub repository
#                       Attached policies: AmazonEC2ContainerRegistryPowerUser,
#                                          AdministratorAccess (scoped in production)
#
# Authentication flow:
#   GitHub Actions → presents OIDC token → AWS STS validates against provider
#                 → assumes gha-oidc-role → gets temporary credentials
#                 → runs Terraform / deploys to ECS
#
# Usage:
#   cd bootstrap/
#   terraform init
#   terraform apply
#   Copy gha-oidc-role-arn output → store as GitHub repository variable GHA_OIDC_ROLE_ARN
#
# WARNING:
#   Do NOT run terraform destroy on this configuration.
#   Destroying the OIDC role will break all GitHub Actions pipelines immediately.
#
# State:
#   Local state only. This configuration is applied once and rarely modified.
#
# Inputs:  aws-region, environment, project-owner, github-repo
# Outputs: gha-oidc-role-arn
# =============================================================================

provider "aws" {
  region = "ap-south-1"
}

# OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "gha-oidc-provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [ "sts.amazonaws.com" ]
  thumbprint_list = [ "6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd" ]
}

# IAM role for GitHub Actions OIDC authentication
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
      values = [ "repo:${var.github-repo}:*" ]
    }
  }
}

# OIDC role for GitHub Actions
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

# Attach policies to the OIDC role (adjust in production for least privilege)
resource "aws_iam_role_policy_attachment" "gha-terraform-policy" {
  role = aws_iam_role.gha-oidc-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}