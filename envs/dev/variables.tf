# envs/dev/variables.tf or a common variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

variable "availability_zones" {
  description = "AWS Sunets Avaialbility zones"
  type        = list(string)
}

variable "environment" {
  description = "Application running environment"
  type        =  string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "subnet_name" {
  description = "Name prefix for subnets"
  type        = string
}

variable "vpc_name" {
  description = "Vpc name"
  type        = string
}

variable "vpc_cidr" {
  description = "Vpc Cidrs"
  type        = string
}

variable "ecr_repository_name" {
  description = "AWS ECR Repository Name"
  type        = string
}


variable "github_token" {
  type = string
  sensitive = true
}

variable "repo_owner" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "build_project_name" {
  type = string
}

variable "buildspec_location" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  description = "The ARN of the AWS CodeStar connection to GitHub"
}

variable "domain_name" {
  type        = string
  description = "Domain name artifactory"
}

variable "pipelines" {
  type = list(object({
    pipeline_name       = string
    repo_name           = string
    build_project_name  = string
  }))
}

variable "codebuild_projects" {
  type = list(object({
    build_project_name = string
    buildspec_location = string
  }))
}

variable "codeartifact_repos" {
  type = list(object({
    repository_name       = string
    upstream_repositories = optional(list(string), [])
    external_connections  = optional(list(string), null)
  }))
}

