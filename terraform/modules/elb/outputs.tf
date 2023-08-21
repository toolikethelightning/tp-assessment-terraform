output "elb" {
  value = aws_lb.hello_app_elb
}

output "ecs_target_group" {
  value = aws_lb_target_group.hello_ecs_target_group
}