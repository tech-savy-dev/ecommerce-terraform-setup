resource "aws_cloudfront_distribution" "cdn" {
  enabled             = var.enabled
  comment             = var.comment
  price_class         = var.price_class
  aliases             = var.aliases
  default_root_object = var.default_root_object

  origin {
    # Strip protocol prefix and any path/port to get a bare hostname
    domain_name = split(":", split("/", replace(replace(var.website_bucket_endpoint, "https://", ""), "http://", ""))[0])[0]
    origin_id   = "s3-website-${var.website_bucket_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website-${var.website_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    # AWS managed CachingDisabled policy
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    min_ttl         = 0
    default_ttl     = 0
    max_ttl         = 0
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [var.acm_certificate_arn] : []
    content {
      acm_certificate_arn      = viewer_certificate.value
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  # Fallback: CloudFront default cert only when no aliases and no ACM cert
  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == "" && length(var.aliases) == 0 ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  tags = {
    Name = "cdn-${var.website_bucket_name}"
  }
}
