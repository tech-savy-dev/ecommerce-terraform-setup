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
  description = "AWS Subnets Availability Zones"
  type        = list(string)
}

variable "environment" {
  description = "Application running environment (dev, stage, prod)"
  type        = string
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
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "repo_owner" {
  description = "GitHub repository owner (org or username)"
  type        = string
}

variable "branch" {
  description = "Default git branch to track in CodePipeline"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the AWS CodeStar connection to GitHub"
  type        = string
}

variable "pipelines" {
  description = "List of CodePipeline definitions"
  type = list(object({
    pipeline_name         = string
    repo_name             = string
    build_project_name    = string
    enable_deploy_stage   = optional(bool, false)
    codedeploy_app_name   = optional(string)
    codedeploy_group_name = optional(string)
  }))
}

variable "codebuild_projects" {
  description = "List of CodeBuild project definitions"
  type = list(object({
    build_project_name = string
    buildspec_location = string
  }))
}

variable "codeartifact_repos" {
  description = "List of CodeArtifact repository definitions"
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
  description = "AWS region where ECS is hosted"
  type        = string
}

variable "alb_name" {
  description = "Name prefix for the Application Load Balancer"
  type        = string
}

variable "san_names" {
  description = "Subject Alternative Names (SANs) for the ACM certificate (e.g. [\"www.example.com\"])"
  type        = list(string)
  default     = []
}

variable "website_name" {
  description = "Primary domain name for the website (e.g. example.com)"
  type        = string
}

variable "ig_name" {
  description = "Name prefix for the Internet Gateway"
  type        = string
}

variable "project" {
  description = "Project name — used for resource naming and tagging"
  type        = string
}

variable "use_codedeploy" {
  description = "Whether to use CodeDeploy deployment controller (global default)"
  type        = bool
  default     = false
}

variable "cloudfront_acm_certificate_arn" {
  description = "ARN of an ACM certificate in us-east-1 for the CloudFront custom domain. Must be in us-east-1."
  type        = string
}

variable "auth_service_image_url" {
  description = "Full ECR image URL (including tag) for the auth service (e.g. 123456789.dkr.ecr.region.amazonaws.com/repo:tag)"
  type        = string
}

variable "product_service_image_url" {
  description = "Full ECR image URL (including tag) for the product service"
  type        = string
}
