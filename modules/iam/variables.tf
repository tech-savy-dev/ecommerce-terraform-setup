variable "codestar_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar connection to GitHub"
}

variable "codebuild_role_names" {
  description = "List of CodeBuild IAM role names to attach CodeArtifact access to"
  type        = list(string)
  default     = []
}



