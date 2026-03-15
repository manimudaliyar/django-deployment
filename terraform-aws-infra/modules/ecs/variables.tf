variable "environment" {
  description = "Environment in which the infra is provisioned for"
  type = string
}

variable "project-owner" {
  description = "Owner of this project"
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

variable "ecs-execution-role-arn" {
  description = "ARN of the execution role for the ECS task"
  type = string
}

variable "ecs-task-role-arn" {
  description = "ARN of the task role for the ECS task"
  type = string
}

variable "django-container-image" {
  description = "Container image for the Django application"
  type = string
}

variable "container-port" {
  description = "Port on which the container listens"
  type = number
}

variable "aws-region" {
  description = "AWS region where the resources will be created"
  type = string
}

variable "desired-count" {
  description = "Number of desired tasks for the ECS service"
  type = number
}

variable "ecs-sg-id" {
  description = "Security group ID for the ECS service"
  type = string
}

variable "private-subnet-1-id" {
  description = "ID of the first private subnet for the ECS service"
  type = string
}

variable "private-subnet-2-id" {
  description = "ID of the second private subnet for the ECS service"
  type = string
}

variable "alb-target-group-arn" {
  description = "ARN of the ALB target group to associate with the ECS service"
  type = string
}