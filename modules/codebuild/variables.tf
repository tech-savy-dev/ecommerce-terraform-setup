variable "build_project_name" {
  type = string
}

variable "buildspec_location" {
  type = string
}

variable "service_role_arn" {
  type        = string
  description = "IAM role ARN to attach to the CodeBuild project"
}

variable "codeartifact_policy_arn" {
  description = "IAM policy ARN for accessing AWS CodeArtifact"
  type        = string
}

variable "website_bucket" {
  description = "Optional S3 bucket name for website hosting to be passed as env var to builds"
  type        = string
  default     = ""
}