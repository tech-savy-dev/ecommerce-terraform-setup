locals {
  all_repositories = concat(var.ecr_existing, var.ecr_to_create)
}

resource "aws_ecr_repository" "this" {
  for_each = { for name in var.ecr_to_create : name => name }

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Name        = each.value
  }
}