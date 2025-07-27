terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "networking" {
  source         = "./modules/networking"
  cidr_block     = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets= ["10.0.101.0/24", "10.0.102.0/24"]
}

module "kafka_ecr" {
  source = "./modules/ecr"
  name   = "siem-kafka"
}

module "ecs_service" {
  source                  = "./modules/ecs-service"
  cluster_id              = module.ecs.cluster_id
  capacity_provider_name  = module.ecs.capacity_provider_name
  repo_url                = module.kafka_ecr.repository_url
  desired_count           = 1
}

module "ecs" {
  source                   = "./modules/ecs"
  cluster_name             = "siem-kafka-cluster"
  vpc_id                   = module.networking.vpc_id
  private_subnet_ids       = module.networking.private_subnet_ids
  kafka_security_group_id  = module.networking.kafka_security_group_id

  instance_type    = "t3.small"
  desired_capacity = 1  # how many nodes
}
