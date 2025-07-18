variable "services" {
  type = list(object({
    service_name         = string
    blue_target_group_name  = string
    green_target_group_name = string
  }))
}

variable "vpc_id" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "target_group_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/actuator/health"
}
