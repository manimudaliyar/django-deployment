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

variable "alb-sg-id" {
  description = "Security group ID of the ALB"
  type = string
}

variable "public-subnet-1" {
  description = "1st Public Subnet ID for the ALB"
  type = string
}

variable "public-subnet-2" {
  description = "2nd Public Subnet ID for the ALB"
  type = string
}