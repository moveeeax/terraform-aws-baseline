resource "aws_s3_bucket" "logs" {
  bucket        = var.log_bucket_name
  force_destroy = var.log_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length      = var.minimum_password_length
  require_symbols              = var.require_symbols
  require_numbers              = var.require_numbers
  require_uppercase_characters = var.require_uppercase_characters
  require_lowercase_characters = var.require_lowercase_characters
  max_password_age             = var.max_password_age
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = var.enable_ebs_encryption_by_default
}
