resource "aws_ecr_repository" "this" {
  name = "${var.ecr_repository_name}-${var.environment}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Name        = "${var.ecr_repository_name}-${var.environment}"
  }
}
