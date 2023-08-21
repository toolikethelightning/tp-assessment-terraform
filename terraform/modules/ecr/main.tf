resource "aws_ecr_repository" "hello_app_ecr_repo" {
  name = "hello-app-ecr-repo"
  tags = {
    Name = "hello-app-ecr-repo"
    Project = "hello-app"
  }
}