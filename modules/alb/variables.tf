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

variable "target_group_port" {
  description = "Port on which target group will receive traffic"
  type        = number
}

variable "target_type" {
  description = "Target type for the target group (e.g., ip, instance, lambda)"
  type        = string
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}