variable "name_prefix" {
  description = "Prefix for unique resource names"
  default     = "gousiya"
}

variable "app_name" {
  description = "Name of the Strapi application"
  default     = "strapi"
}

variable "ecr_repo_url" {
  description = "The ECR repository URL (e.g., 607700977843.dkr.ecr.us-east-2.amazonaws.com/strapi-ecs-fargate)"
  type        = string
}

variable "image_tag" {
  description = "The Docker image tag for ECS deployment"
  default     = "latest"
}

