variable "aws-region" {
  description = "AWS region where the resources will be created"
  type = string
}

variable "environment" {
  description = "Environment in which the infra is provisioned for"
  type = string
}

variable "project-owner" {
  description = "Owner of this project"
  type = string
}