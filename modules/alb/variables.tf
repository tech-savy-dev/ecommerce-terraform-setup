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
  type = map(string)
  description = "Map of service_name to blue target group ARN"
}