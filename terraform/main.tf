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