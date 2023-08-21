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