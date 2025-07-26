output "repository_url" {
  description = "The URI to use for pushing/pulling images"
  value       = aws_ecr_repository.this.repository_url
}
