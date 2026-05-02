variable "bucket_name" {
  description = "Name of the S3 artifact bucket"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects (use with caution)"
  type        = bool
  default     = false
}
