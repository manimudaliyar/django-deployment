variable "vpc-cidr-block" {
  description = "CIDR block for VPC"
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

variable "subnet-index-public" {
    description = "Subnet index for public subnet CIDR"
    type = number
}

variable "subnet-index-public-2" {
    description = "Subnet index for second public subnet CIDR"
    type = number
}

variable "subnet-index-private" {
    description = "Subnet index for private subnet CIDR"
    type = number
}

variable "subnet-index-private-2" {
    description = "Subnet index for second private subnet CIDR"
    type = number
}

variable "availability-zone" {
  description = "Availability zone for public subnet"
  type = string
}

variable "availability-zone-2" {
  description = "Availability zone for second public subnet"
  type = string
}

variable "aws-region" {
  description = "AWS region where the resources will be created"
  type = string
}

variable "retention-in-days" {
  description = "Value of the retention of the logs in days"
  type = number
}

variable "ecs-task-cpu" {
  description = "CPU units for the ECS task"
  type = number
}

variable "ecs-task-memory" {
  description = "Memory for the ECS task"
  type = number
}

variable "django-container-image" {
  description = "Container image for the Django application"
  type = string
}

variable "container-port" {
  description = "Port on which the container listens"
  type = number
}

variable "desired-count" {
  description = "Number of desired tasks for the ECS service"
  type = number
}