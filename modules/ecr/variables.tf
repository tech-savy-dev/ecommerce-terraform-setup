variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
}

variable "ecr_existing" {
  description = "List of ECR repositories that already exist (imported)"
  type        = list(string)
  default     = []
}

variable "ecr_to_create" {
  description = "List of new ECR repositories to create"
  type        = list(string)
}
