# envs/dev/variables.tf or a common variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

variable "availability_zones" {
  description = "AWS Sunets Avaialbility zones"
  type        = list(string)
}

variable "environment" {
  description = "Application running environment"
  type        =  string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "subnet_name" {
  description = "Name prefix for subnets"
  type        = string
}

variable "vpc_name" {
  description = "Vpc name"
  type        = string
}

variable "vpc_cidr" {
  description = "Vpc Cidrs"
  type        = string
}

variable "ecr_repository_name" {
  description = "AWS ECR Repository Name"
  type        = string
}