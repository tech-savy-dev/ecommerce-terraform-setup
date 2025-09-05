variable "codestar_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar connection to GitHub"
}

variable "codebuild_role_names" {
  description = "List of CodeBuild IAM role names to attach CodeArtifact access to"
  type        = list(string)
  default     = []
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "artifact_bucket" {
  description = "Artifact Bucket"
  type        = string
}

variable "website_bucket" {
  description = "Optional website S3 bucket name to grant CodeBuild access for uploading UI assets"
  type        = string
  default     = ""
}


