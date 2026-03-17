locals {
  common_tags = {
    Environment = var.environment
    Project = "terraform-aws-infra"
    Owner = var.project-owner
    ManagedBy = "Terraform"
  }
}