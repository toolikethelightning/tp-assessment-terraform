output "hello_vpc" {
  value = aws_vpc.hello_vpc
}

output "load_balancer_subnet_a" {
  value = aws_subnet.public_subnet_a
}
output "load_balancer_subnet_b" {
  value = aws_subnet.public_subnet_b
}

output "ecs_subnet_a" {
  value = aws_subnet.private_subnet_a
}
output "ecs_subnet_b" {
  value = aws_subnet.private_subnet_b
}

output "load_balancer_sg" {
  value = aws_security_group.load_balancer
}

output "ecs_sg" {
  value = aws_security_group.ecs_task
}
