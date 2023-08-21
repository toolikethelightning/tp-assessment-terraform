output "ecs_cluster" {
  value = aws_ecs_cluster.hello_app_ecs_cluster
}

output "ecs_service" {
  value = aws_ecs_service.hello_app_ecs_service
}