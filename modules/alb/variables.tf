variable "alb_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "blue_target_group_arns" {
  description = "Map of service_name to blue target group ARN"
  type        = map(string)
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection. Set to false only for non-production environments."
  type        = bool
  default     = true
}