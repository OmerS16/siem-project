# 1. Task Definition
resource "aws_ecs_task_definition" "kafka" {
  family                   = "siem-kafka"
  network_mode             = "host"            # host network so container ports map to EC2 host
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "2048"

  # no volumes needed for host mode; data is ephemeral unless you mount EBS/EFS later

  container_definitions = jsonencode([
    {
      name      = "kafka"
      image     = "${var.repo_url}:latest"
      essential = true

      # expose both container ports
      portMappings = [
        { containerPort = 9092, hostPort = 9092, protocol = "tcp" },
        { containerPort = 9093, hostPort = 9093, protocol = "tcp" }
      ]

      # KRaft mode env vars
      environment = [
        { name = "KAFKA_ENABLE_KRAFT",              value = "yes" },
        { name = "KAFKA_BROKER_ID",                 value = "1"   },
        { name = "KAFKA_LISTENERS",                 value = "PLAINTEXT://:9092,CONTROLLER://:9093" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS",  value = "1@localhost:9093" }
        # optionally: { name = "KAFKA_CLUSTER_ID", value = "<uuid>" }
      ]
    }
  ])
}

# 2. ECS Service
resource "aws_ecs_service" "kafka" {
  name            = "siem-kafka-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.kafka.arn

  desired_count                    = var.desired_count
  launch_type                      = "EC2"
  platform_version                 = "LATEST"

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
  }

  # Use host networking, so no network_configuration block is needed
  depends_on = [
    aws_ecs_task_definition.kafka
  ]
}
