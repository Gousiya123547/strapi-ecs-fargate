resource "aws_ecs_task_definition" "strapi" {
  family                   = "${var.name_prefix}-${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::607700977843:role/ecs-task-execution-role"

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-${var.app_name}"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi_postgres.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapidb" },
        { name = "DATABASE_USERNAME", value = "strapi" },
        { name = "DATABASE_PASSWORD", value = "strapi123" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name_prefix}-${var.app_name}"
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "strapi" {
  name            = "${var.name_prefix}-${var.app_name}-service"
  cluster         = aws_ecs_cluster.strapi.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi.arn
    container_name   = "${var.name_prefix}-${var.app_name}"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi]
}

