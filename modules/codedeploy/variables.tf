variable "app_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "codedeploy_role_arn" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "https_listener_arn" {
  type = string
}

variable "priority" {
  type = number
}

variable "path_pattern" {
  type = string
}

variable "blue_target_group_name" {
  type = string
}

variable "green_target_group_name" {
  type = string
}

variable "blue_target_group_arn" {
  type = string
}

variable "green_target_group_arn" {
  type = string
}
