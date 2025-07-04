resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name         # e.g., "example.com"
  subject_alternative_names = var.san_names           # e.g., ["www.example.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
