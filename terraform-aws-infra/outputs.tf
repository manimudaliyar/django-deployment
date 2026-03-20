output "ecs-cluster-name" {
  value = module.ecs.ecs-cluster-name
}

output "ecs-service-name" {
  value = module.ecs.ecs-service-name
}

output "alb-dns-name" {
  value = module.alb.alb-dns-name
}