variable "vpc_id" {
  type        = string
  description = "VPC ID where the endpoints will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the VPC endpoints"
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
  description = "Ecs security group"
  type        = string
}

