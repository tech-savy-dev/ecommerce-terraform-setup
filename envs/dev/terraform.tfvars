# terraform.tfvars for dev environment
vpc_cidr = "10.0.0.0/16"
vpc_name = "ecommerce-dev-vpc"
public_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24"
]
private_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
subnet_name  = "ecommerce-subnet"
ecr_repository_name= "ecommerce-product-service"
environment = "dev"


