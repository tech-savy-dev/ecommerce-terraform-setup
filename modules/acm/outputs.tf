output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "validation_records" {
  value = aws_acm_certificate.cert.domain_validation_options
}
