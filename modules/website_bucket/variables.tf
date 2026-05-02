variable "bucket_name" {
  description = "Name of the website S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "enable_website" {
  description = "Whether to enable S3 static website hosting and public read policy"
  type        = bool
  default     = true
}
