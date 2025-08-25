variable "name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
  description = "Public subnets where NAT Gateway(s) will be placed"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "Private subnets to route through NAT Gateway(s)"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "Optional existing private route tables; if provided, Terraform will only add NAT routes"
  default     = []
}

variable "natgw_per_az" {
  type        = bool
  description = "true: one NAT GW per AZ; false: single NAT GW for all private subnets"
  default     = true
}
