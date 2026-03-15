# ECS Service Name Output
output "ecs-service-name" {
  description = "Name of the ECS service"
  value = aws_ecs_service.django-ecs-service.name
}

# ECS cluster name output
output "ecs-cluster-name" {
  description = "Name of the ECS cluster"
  value = aws_ecs_cluster.django-ecs-cluster.name
}