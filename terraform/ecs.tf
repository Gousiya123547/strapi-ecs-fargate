resource "aws_ecs_cluster" "gkk_strapi" {
  name = "gkk-strapi-cluster"
}

resource "aws_ecs_task_definition" "gkk_strapi" {
  family                   = "gkk-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::607700977843:role/ecs-task-execution-role"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "gkk_strapi" {
  name            = "gkk-strapi-service"
  cluster         = aws_ecs_cluster.gkk_strapi.id
  task_definition = aws_ecs_task_definition.gkk_strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.gkk_strapi.id]
  }
}

