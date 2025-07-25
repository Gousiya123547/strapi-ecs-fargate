variable "name_prefix" {
  description = "Prefix for unique resource names"
  default     = "gousiya"
}

variable "app_name" {
  description = "Application name"
  default     = "strapi"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "strapi" {
  name        = "${var.name_prefix}-${var.app_name}-sg"
  description = "Allow HTTP and DB access"
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

  # Allow Postgres (5432) access from ECS tasks
  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_ecs_cluster" "strapi" {
  name = "${var.name_prefix}-${var.app_name}-cluster"
}

resource "aws_lb" "strapi" {
  name               = "${var.name_prefix}-${var.app_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.strapi.id]
}

resource "aws_lb_target_group" "strapi" {
  name        = "${var.name_prefix}-${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}

resource "aws_lb_listener" "strapi" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }
}

# RDS PostgreSQL Database
resource "aws_db_subnet_group" "strapi_postgres" {
  name       = "${var.name_prefix}-strapi-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${var.name_prefix}-strapi-db-subnet-group"
  }
}

resource "aws_db_instance" "strapi_postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  identifier             = "${var.name_prefix}-strapi-db"
  name                   = "strapidb"
  username               = "strapi"
  password               = "strapi123"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.strapi.id]
  db_subnet_group_name   = aws_db_subnet_group.strapi_postgres.name
}

