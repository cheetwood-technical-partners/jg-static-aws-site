resource "aws_s3_bucket" "www_bucket" {
  bucket = "www-${var.bucket_name}"
  tags   = var.common_tags
}

resource "aws_s3_bucket_policy" "www_bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = templatefile("templates/s3-policy.json", { bucket = "www-${var.bucket_name }"})
}


resource "aws_s3_bucket_acl" "www_bucket_acl" {
  bucket = aws_s3_bucket.www_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "www_cors_configuration" {
  bucket = aws_s3_bucket.www_bucket.bucket

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "www_bucket_website_configuration" {
  bucket = aws_s3_bucket.www_bucket.bucket

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.bucket_name
  tags   = var.common_tags
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = templatefile("templates/s3-policy.json", { bucket = var.bucket_name })
}

resource "aws_s3_bucket_acl" "root_bucket_acl" {
  bucket = aws_s3_bucket.root_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "root_bucket_website_configuration" {
  bucket = aws_s3_bucket.root_bucket.bucket

  redirect_all_requests_to {
    host_name = "https://www.${var.domain_name}"
  }
}

resource "aws_s3_bucket_object" "mp4_file_upload" {
  bucket = var.bucket_name
  key    = "Garrison.Main.mp4"
  source = "${path.module}/files/Garrison.Main.mp4"
  etag   = "${filemd5("${path.module}/files/Garrison.Main.mp4")}"
}

resource "aws_s3_bucket_object" "index_file_upload" {
  bucket = var.bucket_name
  key    = "index.html"
  source = "${path.module}/files/index.html"
  etag   = "${filemd5("${path.module}/files/index.html")}"
  content_type = "text/html"
}