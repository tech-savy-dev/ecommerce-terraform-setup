output "bucket_name" {
  description = "Name of the website S3 bucket"
  value       = aws_s3_bucket.website.bucket
}

output "website_endpoint" {
  description = "S3 static website endpoint URL (HTTP)"
  value       = aws_s3_bucket_website_configuration.website_cfg.website_endpoint
}

output "bucket_arn" {
  description = "ARN of the website S3 bucket"
  value       = aws_s3_bucket.website.arn
}
