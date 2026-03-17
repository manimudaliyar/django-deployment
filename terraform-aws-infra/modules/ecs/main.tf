# =============================================================================
# Module: ECS
# =============================================================================
# This module provisions the compute layer for the Django deployment
# using AWS ECS Fargate.
#
# Resources created:
#   - CloudWatch Log Group   — stores container logs from ECS tasks
#                              retention configurable via variable
#   - ECS Cluster            — logical grouping for ECS tasks and services
#   - ECS Task Definition    — defines the container (image, CPU, memory,
#                              port mappings, logging, IAM roles)
#   - ECS Service            — maintains desired count of running tasks,
#                              wires tasks to ALB target group
#
# Key decisions:
#   - launch_type = "FARGATE" — serverless, no EC2 instances to manage
#   - network_mode = "awsvpc" — each task gets its own ENI (required for Fargate)
#   - assign_public_ip = false — tasks are in private subnets, unreachable directly
#   - container logs ship to CloudWatch via awslogs driver
#
# Traffic flow:
#   ALB Target Group → ECS Service → ECS Tasks (port 8000) → Django App
#
# Inputs:  environment, project-owner, aws-region, retention-in-days,
#          ecs-task-cpu, ecs-task-memory, ecs-execution-role-arn,
#          ecs-task-role-arn, django-container-image, container-port,
#          desired-count, ecs-sg-id, private-subnet-1-id,
#          private-subnet-2-id, alb-target-group-arn
# Outputs: ecs-service-name, ecs-cluster-name
# =============================================================================

# ECS Cluster, Task Definition, and Service for Django Application
# ECS CloudWatch Log Group for ECS Task Logs
resource "aws_cloudwatch_log_group" "ecs-cloudwatch-log-group" {
  name = "/aws/ecs/${var.environment}-log-group"
  retention_in_days = var.retention-in-days
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-log-group"
    }
  )
}

# ECS Cluster for Django Application
resource "aws_ecs_cluster" "django-ecs-cluster" {
  name = "${var.environment}-django-ecs-cluster"
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-ecs-cluster"
    }
  )
}

# ECS Task Definition for Django Application
resource "aws_ecs_task_definition" "django-ecs-task-definition" {
  family = "${var.environment}-django-ecs-task-definition"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.ecs-task-cpu
  memory = var.ecs-task-memory
  execution_role_arn = var.ecs-execution-role-arn
  task_role_arn = var.ecs-task-role-arn

  # Define the container for the Django application
  container_definitions = jsonencode([
    {
        name = "django-container"
        image = var.django-container-image
        essential = true
        portMappings = [
            {
                containerPort = var.container-port
                protocol = "tcp"
            }
        ]
        
        # Configure logging to CloudWatch Logs
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.ecs-cloudwatch-log-group.name
                awslogs-region = var.aws-region
                awslogs-stream-prefix = "ecs"
            }
        }
    }
  ])
}

# ECS Service for Django Application
resource "aws_ecs_service" "django-ecs-service" {
  name = "${var.environment}-django-ecs-service"
  cluster = aws_ecs_cluster.django-ecs-cluster.id
  task_definition = aws_ecs_task_definition.django-ecs-task-definition.arn
  desired_count = var.desired-count
  launch_type = "FARGATE"

# Configure the network settings for the ECS service
  network_configuration {
    security_groups = [var.ecs-sg-id]
    subnets = [var.private-subnet-1-id, var.private-subnet-2-id]
    assign_public_ip = false
  }

# Configure the load balancer for the ECS service
  load_balancer {
    container_name = "django-container"
    container_port = var.container-port
    target_group_arn = var.alb-target-group-arn
  }

  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-ecs-service"
    }
  )
}