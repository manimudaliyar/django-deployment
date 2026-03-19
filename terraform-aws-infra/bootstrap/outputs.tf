output "gha-role-arn" {
  value = aws_iam_role.gha-oidc-role.arn
  description = "ARN of the IAM role for GitHub Actions OIDC provider"
}