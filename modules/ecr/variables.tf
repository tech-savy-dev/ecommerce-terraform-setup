variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

variable "ecr_existing" {
  description = "List of ECR repositories that already exist (imported, not managed by Terraform)"
  type        = list(string)
  default     = []
}

variable "ecr_to_create" {
  description = "List of new ECR repositories to create"
  type        = list(string)
}

variable "max_image_count" {
  description = "Maximum number of tagged images to retain per repository. Older images are expired."
  type        = number
  default     = 10
}
