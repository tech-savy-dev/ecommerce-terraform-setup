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
    enable_deploy_stage   = optional(bool, false)
    codedeploy_app_name   = optional(string)
    codedeploy_group_name = optional(string)
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


variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name for the ECS security group"
  type        = string
}

variable "security_groups" {
  description = "Security groups for ECS services"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Region ECS hosted"
  type        = string
}


variable "alb_name" {
  description = "Name of ALB"
  type        = string
}

variable "san_names" {
  description = "Name of San Names dns"
  type        = list(string)
  default     = []
}

variable "website_name" {
  description = "Website Name"
  type        = string
}

variable "ig_name" {
  description = "Internet Gateway Name"
  type        = string
}

variable "project" {
  description = "Project Name"
  type        = string
}


variable "use_codedeploy" {
  description = "Whether to use CodeDeploy deployment controller"
  type        = bool
  default     = false
}











