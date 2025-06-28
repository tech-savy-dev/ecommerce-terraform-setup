# main.tf for dev environment
module "vpc" {
  source = "../../modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
}

module "subnets" {
  source               = "../../modules/subnets"
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  subnet_name = var.subnet_name

}


module "ecr" {
  source              = "../../modules/ecr"
  ecr_repository_name = var.ecr_repository_name
  environment         = var.environment
}
