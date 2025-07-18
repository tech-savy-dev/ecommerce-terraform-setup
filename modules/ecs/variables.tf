variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable "ecs_tasks" {
  type = list(object({
    task_name       = string
    task_family     = string
    container_name  = string
    image_url       = string
    container_port  = number
    cpu             = string
    memory          = string
    service_name    = string
    desired_count   = number
    assign_public_ip= bool
    use_codedeploy  = bool
  }))
  description = "List of ECS tasks with settings"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID to allow traffic from"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS tasks"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "service_name" {
  type        = string
  description = "Base service name (used for security group tagging)"
}

variable "blue_target_group_arns" {
  type        = map(string)
  description = "Map of service_name -> blue target group ARN"
}