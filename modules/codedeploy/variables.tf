variable "app_name" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "codedeploy_role_arn" {}
variable "blue_target_group_name" {
  type = string
}

variable "green_target_group_name" {
  type = string
}

variable "listener_arn" {}
variable "tags" {
  type    = map(string)
  default = {}
}