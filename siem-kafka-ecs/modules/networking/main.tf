# Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = { Name = "siem-vpc" }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "siem-igw" }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "siem-public-rt" }
}

# ---------------------------------------------------
# Create one public subnet per AZ
# ---------------------------------------------------
resource "aws_subnet" "public" {
  for_each = zipmap(var.availability_zones, var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "siem-public-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------
# Create one private subnet per AZ
# ---------------------------------------------------
resource "aws_subnet" "private" {
  for_each         = zipmap(var.availability_zones, var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "siem-private-${each.key}"
  }
}

# Security Group for Kafka
resource "aws_security_group" "kafka" {
  name        = "siem-kafka-sg"
  description = "Allow Kafka broker+controller ports"
  vpc_id      = aws_vpc.this.id

  # Broker client port
  ingress {
    description      = "Kafka client"
    from_port        = 9092
    to_port          = 9092
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # KRaft controller port
  ingress {
    description      = "Kafka controller"
    from_port        = 9093
    to_port          = 9093
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "siem-kafka-sg" }
}
