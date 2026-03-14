variable "environment" {
  description = "Environment in which the infra is provisioned for"
  type = string
}

variable "project-owner" {
  description = "Owner of this project"
  type = string
}

variable "vpc-id" {
  description = "VPC ID from vpc module which provides the vpc_id output"
  type = string
}