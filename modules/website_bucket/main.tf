resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "website_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_policy" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.website.id

  # Public access block must be removed before a public bucket policy can be applied
  depends_on = [aws_s3_bucket_public_access_block.website_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.website.arn}/*"]
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "website_lifecycle" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "expire-objects"
    status = "Enabled"
    filter { prefix = "" }

    expiration {
      days = 3650
    }
  }
}

resource "aws_s3_bucket_website_configuration" "website_cfg" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
