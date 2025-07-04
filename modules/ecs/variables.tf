variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecs_tasks" {
  description = "List of ECS tasks"
  type = list(object({
    task_name        = string
    task_family      = string
    container_name   = string
    image_url        = string
    container_port   = number
    service_name     = string
    cpu              = string
    memory           = string
    desired_count    = number
    assign_public_ip = bool
  }))
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups for ECS services"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The VPC ID to associate with the ECS resources"
  type        = string
}

variable "service_name" {
  description = "The service name for the ECS service"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "Ecs to pull images from ECR"
  type        = string
}

variable "region" {
  description = "Region for all"
  type        = string
}
