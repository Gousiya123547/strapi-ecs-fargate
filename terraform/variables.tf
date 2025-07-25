variable "app_name" {
  description = "Name of the Strapi application"
  default     = "strapi"
}

variable "ecr_repo_url" {
  description = "The ECR repository URL"
}

variable "image_tag" {
  description = "The Docker image tag"
  default     = "latest"
}

