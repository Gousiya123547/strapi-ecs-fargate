variable "name_prefix" {
  description = "Prefix to make resource names unique"
  default     = "gousiya"
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all subnets from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for Strapi
resource "aws_security_group" "strapi" {
  name        = "${var.name_prefix}-${var.app_name}-sg"
  description = "Allow HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi" {
  name = "${var.name_prefix}-${var.app_name}-cluster"
}

# Load Balancer
resource "aws_lb" "strapi" {
  name               = "${var.name_prefix}-${var.app_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.strapi.id]
}

# Target Group
resource "aws_lb_target_group" "strapi" {
  name        = "${var.name_prefix}-${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}

# Listener
resource "aws_lb_listener" "strapi" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }
}

