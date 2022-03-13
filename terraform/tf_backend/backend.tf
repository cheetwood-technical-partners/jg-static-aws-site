provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "jg-static-aws-site-terraform-state-backend"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_remote_state" {
  bucket = aws_s3_bucket.tf_remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_remote_state" {
  bucket = aws_s3_bucket.tf_remote_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_remote_state_locking" {
  hash_key = "LockID"
  name     = "jg-static-aws-site-terraform-state-locking"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}
