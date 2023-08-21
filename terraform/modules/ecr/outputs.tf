output "ecr_path" {
    value = aws_ecr_repository.hello_app_ecr_repo.repository_url
}