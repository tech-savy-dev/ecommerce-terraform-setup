variable "name" {
  description = "Name prefix for NAT Gateway and related resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where NAT Gateways will be created"
  type        = string
}

variable "azs" {
  description = "List of availability zones (used when natgw_per_az = true)"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnets where NAT Gateway(s) will be placed"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets to route through NAT Gateway(s)"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Optional existing private route table IDs; if provided, only NAT routes are added (no new tables created)"
  type        = list(string)
  default     = []
}

variable "natgw_per_az" {
  description = "When true, one NAT Gateway per AZ is created for HA; when false, a single shared NAT Gateway is used"
  type        = bool
  default     = true
}
