resource "aws_ecs_cluster" "hello_app_ecs_cluster" {
    name = "hello-app-ecs-cluster"
    capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "hello_app_task_definition" {
  family = "hello_app"
  container_definitions = <<TASK_DEFINITION
  [
  {
    "portMappings": [
      {
        "hostPort": 5001,
        "protocol": "tcp",
        "containerPort": 5001
      }
    ],
    "cpu": 512,
    "environment": [
      {
        "name": "FLASK_APP",
        "value": "hello"
      }
    ],
    "memory": 1024,
    "image": "${format("%s%s",var.ecr_path,":latest")}",
    "essential": true,
    "name": "hello"
}
  }
]
TASK_DEFINITION
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory = "1024"
  cpu = "512"
  execution_role_arn = var.ecs_role.arn
  task_role_arn = var.ecs_role.arn
}

resource "aws_ecs_service" "hello_app_ecs_service" {
  name = "hello-app-ecs-service"
  cluster = aws_ecs_cluster.hello_app_ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_app_task_definition.arn
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "1.4.0" # TODO: worth making this a variable

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [var.ecs_subnet_a.id, var.ecs_subnet_b.id]
    security_groups = [var.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.ecs_target_group.arn
    container_name = "hello"
    container_port = 5001
  }
}