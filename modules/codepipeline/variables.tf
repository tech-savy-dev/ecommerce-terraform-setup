variable "github_token" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "build_project_name" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "repo_owner" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "pipeline_name" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar connection to GitHub"
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
  description = "Optional S3 bucket name for website hosting"
  type        = string
  default     = ""
}

variable "enable_deploy_stage" {
  type        = bool
  description = "Whether to enable deploy stage"
  default     = false
}

variable "codedeploy_app_name" {
  type        = string
  description = "CodeDeploy ECS Application name"
  default     = ""
}

variable "codedeploy_group_name" {
  type        = string
  description = "CodeDeploy ECS Deployment group name"
  default     = ""
}
