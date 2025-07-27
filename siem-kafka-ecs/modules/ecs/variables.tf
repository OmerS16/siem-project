variable "cluster_name" {
  description = "Name for the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC to launch into"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for ECS nodes"
  type        = list(string)
}

variable "kafka_security_group_id" {
  description = "Security Group for your Kafka ports"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ECS nodes"
  type        = string
  default     = "t3.small"
}

variable "desired_capacity" {
  description = "How many EC2 nodes to run"
  type        = number
  default     = 2
}
