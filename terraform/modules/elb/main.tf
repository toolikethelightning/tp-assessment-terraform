resource "aws_lb" "hello_app_elb" {
  name               = "hello-app-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.load_balancer_sg.id]
  subnets            = [
    var.load_balancer_subnet_a.id,
    var.load_balancer_subnet_b.id,
  ]
}

resource "aws_lb_target_group" "hello_ecs_target_group" {
  name     = "ecs"
  port     = 5001
  protocol = "HTTP"
  vpc_id   = var.hello_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.hello_app_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_ecs_target_group.arn
  }
}