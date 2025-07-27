output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.this.name
}
