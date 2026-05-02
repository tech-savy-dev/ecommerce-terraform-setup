variable "app_name" {
  description = "Name of the CodeDeploy application (matches ECS service name)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster where the service runs"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service managed by this deployment group"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "IAM role ARN that CodeDeploy assumes to perform deployments"
  type        = string
}

variable "https_listener_arn" {
  description = "ARN of the ALB HTTPS listener used for traffic routing during blue/green deployments"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
}

variable "termination_wait_minutes" {
  description = "Minutes to wait before terminating the original (blue) task set after a successful deployment"
  type        = number
  default     = 0
}

variable "deployment_config_name" {
  description = "CodeDeploy deployment configuration name for ECS blue/green deployments"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}
