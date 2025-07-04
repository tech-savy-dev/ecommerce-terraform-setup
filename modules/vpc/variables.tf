variable "vpc_cidr" {
  type        = string
  description = "default CIDR range of the VPC"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "ig_name" {
  description = "Name tag for the Ig"
  type        = string
}
