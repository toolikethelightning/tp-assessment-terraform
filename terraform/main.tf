terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
      version = "~> 2.0"
    }
  }

  cloud {
    organization = "tp-assessment"

    workspaces {
      name = "tp-hello-app"
    }
  }
}

data "aws_iam_role" "ecs_role" {
  name = "ecsTaskExecutionRole"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ecr" {
  source = "./modules/ecr"
}

module "elb" {
  source = "./modules/elb"
  load_balancer_sg = module.vpc.load_balancer_sg
  load_balancer_subnet_a = module.vpc.load_balancer_subnet_a
  load_balancer_subnet_b = module.vpc.load_balancer_subnet_b
  hello_vpc = module.vpc.hello_vpc
}

module "ecs" {
  source = "./modules/ecs"
  ecs_role = data.aws_iam_role.ecs_role
  ecs_sg = module.vpc.ecs_sg
  ecs_subnet_a = module.vpc.ecs_subnet_a
  ecs_subnet_b = module.vpc.ecs_subnet_b
  ecs_target_group = module.elb.ecs_target_group
  ecr_path = module.ecr.ecr_path
}

module "auto_scaling" {
  source = "./modules/autoscaling"
  ecs_cluster = module.ecs.ecs_cluster
  ecs_service = module.ecs.ecs_service
}
