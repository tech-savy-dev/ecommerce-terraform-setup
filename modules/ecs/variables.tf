variable "cluster_arn" {
  type        = string
  description = "ARN of the ECS cluster to deploy services into (cluster is managed outside this module)"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable "ecs_tasks" {
  type = list(object({
    task_name        = string
    task_family      = string
    container_name   = string
    image_url        = string
    container_port   = number
    cpu              = string
    memory           = string
    service_name     = string
    desired_count    = number
    assign_public_ip = bool
    use_codedeploy   = bool
  }))
  description = "List of ECS task/service definitions"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID — ECS ingress is restricted to traffic from this SG"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECS tasks"
}

variable "region" {
  type        = string
  description = "AWS region (used for CloudWatch log group configuration)"
}

variable "service_name" {
  type        = string
  description = "Base service name used for the security group name and tag"
}

variable "blue_target_group_arns" {
  type        = map(string)
  description = "Map of service_name => blue target group ARN (used for initial load balancer attachment)"
}
