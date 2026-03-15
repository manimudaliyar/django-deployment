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

resource "aws_ecs_cluster" "django-ecs-cluster" {
  name = "${var.environment}-django-ecs-cluster"
  tags = merge(
    local.common_tags,
    {
    Name = "${var.environment}-django-ecs-cluster"
    }
  )
}

resource "aws_ecs_task_definition" "django-ecs-task-definition" {
  family = "${var.environment}-django-ecs-task-definition"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.ecs-task-cpu
  memory = var.ecs-task-memory
  execution_role_arn = var.ecs-execution-role-arn
  task_role_arn = var.ecs-task-role-arn
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

resource "aws_ecs_service" "django-ecs-service" {
  name = "${var.environment}-django-ecs-service"
  cluster = aws_ecs_cluster.django-ecs-cluster.id
  task_definition = aws_ecs_task_definition.django-ecs-task-definition.arn
  desired_count = var.desired-count
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [var.ecs-sg-id]
    subnets = [var.private-subnet-1-id, var.private-subnet-2-id]
    assign_public_ip = false
  }

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