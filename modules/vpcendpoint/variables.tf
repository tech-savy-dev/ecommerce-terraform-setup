variable "vpc_id" {
  type        = string
  description = "VPC ID where the endpoints will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for VPC endpoints (ECR and other endpoints use these)"
}

variable "ecr_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECR endpoints (can include public subnets to allow image pulls from public tasks)"
  default     = []
}

variable "region" {
  type        = string
  description = "AWS region (used to form service names)"
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with the S3 gateway endpoint"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS private security group"
  type        = string
}

variable "auth_security_group_id" {
  description = "ECS public auth service security group"
  type        = string
  default     = ""
}

variable "enable_ecs_telemetry" {
  description = "Whether to create the ECS telemetry VPC endpoint"
  type        = bool
  default     = true
}

