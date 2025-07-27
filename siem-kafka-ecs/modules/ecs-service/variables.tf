variable "cluster_id" {
  description = "The ECS cluster ARN or name"
  type        = string
}

variable "capacity_provider_name" {
  description = "The ECS capacity provider to use"
  type        = string
}

variable "repo_url" {
  description = "The ECR repository URI (no tag)"
  type        = string
}

variable "desired_count" {
  description = "How many Kafka tasks to run"
  type        = number
  default     = 1
}
