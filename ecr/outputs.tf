output "ecr_repository_arn" {
  value = [
    "${aws_ecr_repository.app_registry.registry_id}",
  ]
}

output "ecr_repository_url" {
  value = [
    "${aws_ecr_repository.app_registry.repository_url}",
  ]
}
