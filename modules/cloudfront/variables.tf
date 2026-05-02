variable "website_bucket_name" {
  description = "S3 bucket name used for website hosting"
  type        = string
}

variable "website_bucket_endpoint" {
  description = "S3 website endpoint domain (without protocol), e.g. bucket.s3-website-region.amazonaws.com"
  type        = string
}

variable "enabled" {
  description = "Whether to create the CloudFront distribution"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN (must be in us-east-1) to use for custom domain aliases. Leave empty to use the CloudFront default certificate."
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object for CloudFront (e.g. index.html)"
  type        = string
  default     = "index.html"
}

# Validation: if aliases are provided, an ACM certificate ARN must be set (ACM must be in us-east-1)
variable "aliases" {
  description = "Optional CNAMEs for the distribution"
  type        = list(string)
  default     = []

  validation {
    condition     = !(length(var.aliases) > 0 && var.acm_certificate_arn == "")
    error_message = "When 'aliases' is non-empty you must supply 'acm_certificate_arn' (ACM certificate in us-east-1) to enable HTTPS for custom domains."
  }
}
