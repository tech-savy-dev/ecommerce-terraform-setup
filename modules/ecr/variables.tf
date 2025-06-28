variable "ecr_repository_name" {
  description = "Base name for the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
}
